import 'package:dio/dio.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';

/// Central place that turns transport-level errors into typed [Failure]s.
///
/// This is the only file allowed to know about [DioException] outside of
/// `core/network` — data sources catch here, repositories only ever see
/// [Failure]. Nothing above the data layer should import `dio`.
class ApiErrorMapper {
  const ApiErrorMapper();

  Failure map(Object error) {
    if (error is Failure) return error;
    if (error is! DioException) return UnknownFailure(message: error.toString());

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutFailure();

      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.cancel:
        return const UnknownFailure(message: 'Request cancelled');

      case DioExceptionType.badCertificate:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        return _mapStatusCode(error);

      case DioExceptionType.unknown:
        return const NetworkFailure();
    }
  }

  Failure _mapStatusCode(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final message = _extractBackendMessage(response?.data);
    final code = _extractCode(response?.data);

    return switch (statusCode) {
      401 => UnauthorizedFailure(message: message, code: code),
      403 => ForbiddenFailure(message: message, code: code),
      404 => NotFoundFailure(message: message, code: code),
      422 => ValidationFailure(message: message, code: code, fieldErrors: _extractFieldErrors(response?.data)),
      429 => RateLimitedFailure(message: message, code: code, retryAfter: _parseRetryAfter(response?.headers)),
      _ => ServerFailure(message: message, code: code, statusCode: statusCode),
    };
  }

  String? _extractCode(dynamic data) {
    if (data is! Map) return null;
    final error = data['error'];
    final code = error is Map ? error['code'] : data['code'];
    return code is String ? code : null;
  }

  /// `Retry-After` in its delta-seconds form (what the API sends); the
  /// HTTP-date form is ignored rather than guessed at.
  Duration? _parseRetryAfter(Headers? headers) {
    final seconds = int.tryParse(headers?.value('retry-after')?.trim() ?? '');
    return seconds != null && seconds > 0 ? Duration(seconds: seconds) : null;
  }

  /// Backend error envelope shape is not finalized yet — this defensively
  /// reads a couple of common shapes (`message`, `error.message`) and falls
  /// back to null (generic localized message) rather than guessing further.
  String? _extractBackendMessage(dynamic data) {
    if (data is Map) {
      final message = data['message'];
      if (message is String) return message;
      final error = data['error'];
      if (error is Map && error['message'] is String) return error['message'] as String;
    }
    return null;
  }

  Map<String, List<String>> _extractFieldErrors(dynamic data) {
    if (data is! Map) return const {};
    final topLevel = data['errors'];
    final nested = data['error'] is Map ? (data['error'] as Map)['errors'] : null;
    // Prefer whichever candidate is actually a Map — a top-level `errors`
    // that exists but isn't one (e.g. an unrelated list/string field) must
    // not shadow a valid nested `error.errors` envelope.
    final errors = topLevel is Map ? topLevel : nested;
    if (errors is! Map) return const {};
    return errors.map((key, value) {
      final messages = value is List ? value.map((e) => e.toString()).toList() : <String>[value.toString()];
      return MapEntry(key.toString(), messages);
    });
  }
}
