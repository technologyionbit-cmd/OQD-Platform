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
    final statusCode = error.response?.statusCode;
    final backendMessage = _extractBackendMessage(error.response?.data);

    switch (statusCode) {
      case 401:
        return UnauthorizedFailure(message: backendMessage);
      case 403:
        return ForbiddenFailure(message: backendMessage);
      case 404:
        return NotFoundFailure(message: backendMessage);
      case 422:
        return ValidationFailure(
          message: backendMessage,
          fieldErrors: _extractFieldErrors(error.response?.data),
        );
      default:
        if (statusCode != null && statusCode >= 500) {
          return ServerFailure(message: backendMessage, statusCode: statusCode);
        }
        return ServerFailure(message: backendMessage, statusCode: statusCode);
    }
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
    if (data is Map && data['errors'] is Map) {
      final raw = data['errors'] as Map;
      return raw.map((key, value) {
        final messages = value is List ? value.map((e) => e.toString()).toList() : <String>[value.toString()];
        return MapEntry(key.toString(), messages);
      });
    }
    return const {};
  }
}
