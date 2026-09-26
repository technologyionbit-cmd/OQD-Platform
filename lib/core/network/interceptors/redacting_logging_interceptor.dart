import 'package:dio/dio.dart';

import 'package:aqd_ionbit/core/utils/app_logger.dart';

/// Dev/staging-only request logging. Redacts anything that must never hit a
/// log — the auth header, and sensitive body/query fields — instead of
/// logging raw request/response payloads.
class RedactingLoggingInterceptor extends Interceptor {
  /// Matched against the lower-cased key as a substring, so `newPassword`,
  /// `currentPassword`, `refreshToken` and friends are all covered without
  /// listing every variant — a false positive only hides a harmless value.
  static const _sensitiveFragments = {'password', 'token', 'secret', 'otp', 'card', 'cvv', 'iban', 'signature'};

  /// Short keys that are only sensitive as an exact match (a substring
  /// match on "code" would also hide `countryCode`, `postalCode`...).
  static const _sensitiveExactKeys = {'code', 'pin'};

  static const _redacted = '***';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('→ ${options.method} ${_redactUri(options.uri)} body=${redact(options.data)}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    AppLogger.debug('← ${response.statusCode} ${_redactUri(response.requestOptions.uri)}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.warning('✕ ${err.response?.statusCode} ${_redactUri(err.requestOptions.uri)} — ${err.type}');
    handler.next(err);
  }

  /// Visible for testing.
  static Object? redact(Object? data) {
    if (data is Map) {
      return data.map((key, value) => MapEntry(key, _isSensitive(key.toString()) ? _redacted : redact(value)));
    }
    if (data is List) return data.map(redact).toList();
    return data;
  }

  static String _redactUri(Uri uri) {
    if (uri.queryParameters.isEmpty) return uri.toString();
    return uri
        .replace(
          queryParameters: uri.queryParameters.map((key, value) => MapEntry(key, _isSensitive(key) ? _redacted : value)),
        )
        .toString();
  }

  static bool _isSensitive(String key) {
    final normalized = key.toLowerCase();
    return _sensitiveExactKeys.contains(normalized) || _sensitiveFragments.any(normalized.contains);
  }
}
