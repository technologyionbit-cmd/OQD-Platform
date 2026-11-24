import 'dart:async';

import 'package:dio/dio.dart';

import 'package:aqd_admin/core/config/app_config.dart';
import 'package:aqd_admin/core/network/session_store.dart';

/// Header the backend requires on every call that can touch the refresh
/// cookie (CSRF defence). Sent on all requests: it is harmless elsewhere.
const adminClientHeader = 'X-Requested-With';
const adminClientValue = 'aqd-admin';

const _authPrefix = '/admin-auth/';
const _retriedKey = 'aqd_retried';

/// Gets a new access token from the refresh cookie. Returns false when the
/// session is over. Registered by the auth controller.
typedef SessionRefresher = Future<bool> Function();

/// The single [Dio] every feature uses.
///
/// - `withCredentials` so the browser sends/accepts the refresh cookie.
/// - Adds the in-memory access token.
/// - On 401 it refreshes once (concurrent 401s share one refresh) and
///   retries; if refreshing fails the session is over.
class ApiClient {
  ApiClient({required AppConfig config, required this.session, Dio? dio})
      : dio = dio ?? Dio() {
    this.dio.options
      ..baseUrl = config.apiBaseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 30)
      ..headers[adminClientHeader] = adminClientValue
      ..extra['withCredentials'] = true;
    this.dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  final Dio dio;
  final SessionStore session;

  SessionRefresher? _refresher;
  void Function()? _onSessionExpired;
  Future<bool>? _refreshInFlight;

  void registerSessionHandlers({
    required SessionRefresher refresher,
    required void Function() onSessionExpired,
  }) {
    _refresher = refresher;
    _onSessionExpired = onSessionExpired;
  }

  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = session.accessToken;
    if (token != null && !options.path.startsWith(_authPrefix)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(DioException error, ErrorInterceptorHandler handler) async {
    final request = error.requestOptions;
    final isAuthCall = request.path.startsWith(_authPrefix);
    final alreadyRetried = request.extra[_retriedKey] == true;

    if (error.response?.statusCode != 401 || isAuthCall || alreadyRetried || _refresher == null) {
      handler.next(error);
      return;
    }

    final refreshed = await (_refreshInFlight ??= _refresh());
    if (!refreshed) {
      handler.next(error);
      return;
    }

    try {
      request.extra[_retriedKey] = true;
      request.headers['Authorization'] = 'Bearer ${session.accessToken}';
      handler.resolve(await dio.fetch<dynamic>(request));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _refresh() async {
    try {
      final ok = await _refresher!();
      if (!ok) _onSessionExpired?.call();
      return ok;
    } finally {
      // Cleared on the next microtask so everything that awaited this
      // refresh sees the same outcome.
      scheduleMicrotask(() => _refreshInFlight = null);
    }
  }
}
