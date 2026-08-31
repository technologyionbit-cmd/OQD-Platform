import 'package:dio/dio.dart';

import 'package:aqd_ionbit/core/utils/app_logger.dart';

/// Dev/staging-only request logging. Redacts anything that must never hit a
/// log — the auth header, and known-sensitive body/field names — instead of
/// logging raw request/response payloads.
class RedactingLoggingInterceptor extends Interceptor {
  static const _sensitiveKeys = {'password', 'token', 'accessToken', 'refreshToken', 'cardNumber', 'cvv', 'otp'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('→ ${options.method} ${options.uri} body=${_redact(options.data)}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.warning('✕ ${err.response?.statusCode} ${err.requestOptions.uri} — ${err.type}');
    handler.next(err);
  }

  dynamic _redact(dynamic data) {
    if (data is Map) {
      return data.map((key, value) {
        final isSensitive = _sensitiveKeys.contains(key.toString());
        return MapEntry(key, isSensitive ? '***' : _redact(value));
      });
    }
    return data;
  }
}
