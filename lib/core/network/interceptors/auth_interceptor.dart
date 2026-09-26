import 'dart:async';

import 'package:dio/dio.dart';

import 'package:aqd_ionbit/core/network/auth_session_ports.dart';
import 'package:aqd_ionbit/core/network/dio_extra_keys.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';

/// Attaches the access token to outgoing requests and, on a 401, refreshes
/// once and retries — queuing any other requests that 401 while a refresh
/// is already in flight so they don't each trigger their own refresh call.
///
/// [onRefreshToken] and [onSessionExpired] are injected rather than this
/// class knowing about the auth feature directly (`core` must not depend on
/// `features/*`). Persisting refreshed tokens and clearing an ended session
/// are the auth feature's job too — this class only moves requests along.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenManager tokenManager,
    required RefreshTokenFn onRefreshToken,
    required void Function() onSessionExpired,
  }) : _dio = dio,
       _tokenManager = tokenManager,
       _onRefreshToken = onRefreshToken,
       _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final TokenManager _tokenManager;
  final RefreshTokenFn _onRefreshToken;
  final void Function() _onSessionExpired;

  Future<RefreshOutcome>? _refreshInFlight;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final skipAuth = options.extra[DioExtraKeys.skipAuth] == true;
    final token = _tokenManager.current?.accessToken;
    if (!skipAuth && token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra[DioExtraKeys.retried] == true;
    final skipAuth = err.requestOptions.extra[DioExtraKeys.skipAuth] == true;

    if (!isUnauthorized || alreadyRetried || skipAuth) {
      handler.next(err);
      return;
    }

    switch (await _refreshOnce()) {
      case RefreshSucceeded(:final tokens):
        await _retry(err.requestOptions, tokens, handler);
      case RefreshRejected():
        _onSessionExpired();
        handler.next(err);
      case RefreshUnavailable():
        // Surface as a connectivity problem, not a 401 — callers must not
        // treat "couldn't reach the server to refresh" as "signed out".
        handler.next(
          DioException(
            requestOptions: err.requestOptions,
            type: DioExceptionType.connectionError,
            error: 'Token refresh unavailable',
          ),
        );
    }
  }

  Future<void> _retry(RequestOptions options, AuthTokens tokens, ErrorInterceptorHandler handler) async {
    try {
      options.extra[DioExtraKeys.retried] = true;
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Coalesces concurrent 401s into a single refresh call. A refresh that
  /// throws is treated as [RefreshUnavailable] — never as a rejection.
  Future<RefreshOutcome> _refreshOnce() {
    return _refreshInFlight ??= _onRefreshToken()
        .catchError((Object _) => const RefreshUnavailable())
        .whenComplete(() => _refreshInFlight = null);
  }
}
