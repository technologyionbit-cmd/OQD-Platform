import 'dart:async';

import 'package:dio/dio.dart';

import 'package:aqd_ionbit/core/network/dio_extra_keys.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';

/// Attaches the access token to outgoing requests and, on a 401, refreshes
/// once and retries — queuing any other requests that 401 while a refresh
/// is already in flight so they don't each trigger their own refresh call.
///
/// [onRefreshToken] and [onSessionExpired] are injected rather than this
/// class knowing about the auth feature directly (`core` must not depend on
/// `features/*`). Until the real backend is wired, [onRefreshToken] is a
/// no-op that always fails, which simply routes straight to
/// [onSessionExpired] — the seam is ready, nothing here is invented.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenManager tokenManager,
    required Future<AuthTokens?> Function() onRefreshToken,
    required void Function() onSessionExpired,
  }) : _dio = dio,
       _tokenManager = tokenManager,
       _onRefreshToken = onRefreshToken,
       _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final TokenManager _tokenManager;
  final Future<AuthTokens?> Function() _onRefreshToken;
  final void Function() _onSessionExpired;

  Completer<AuthTokens?>? _refreshCompleter;

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
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra[DioExtraKeys.retried] == true;
    final skipAuth = err.requestOptions.extra[DioExtraKeys.skipAuth] == true;

    if (!isUnauthorized || alreadyRetried || skipAuth) {
      handler.next(err);
      return;
    }

    final refreshedTokens = await _refreshOnce();
    if (refreshedTokens == null) {
      _onSessionExpired();
      handler.next(err);
      return;
    }

    try {
      final retryOptions = err.requestOptions;
      retryOptions.extra[DioExtraKeys.retried] = true;
      retryOptions.headers['Authorization'] = 'Bearer ${refreshedTokens.accessToken}';
      final response = await _dio.fetch(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Coalesces concurrent 401s into a single refresh call.
  Future<AuthTokens?> _refreshOnce() {
    final inFlight = _refreshCompleter;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<AuthTokens?>();
    _refreshCompleter = completer;

    _onRefreshToken().then(
      (tokens) async {
        if (tokens != null) await _tokenManager.save(tokens);
        _refreshCompleter = null;
        completer.complete(tokens);
      },
      onError: (_) {
        _refreshCompleter = null;
        completer.complete(null);
      },
    );

    return completer.future;
  }
}
