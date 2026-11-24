import 'package:dio/dio.dart';

/// Every repository throws a [Failure], never a raw Dio/HTTP exception, so
/// screens branch on a type and can never show a raw server message.
sealed class Failure implements Exception {
  const Failure({this.message, this.code});

  /// Backend message, English, for logs only. Screens show localized text.
  final String? message;

  /// Backend `error.code` (e.g. `ACCOUNT_INACTIVE`).
  final String? code;
}

final class NetworkFailure extends Failure {
  const NetworkFailure({super.message});
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message});
}

/// 401: not signed in, or the session could not be refreshed.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message, super.code});
}

/// 403: signed in, but not allowed.
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message, super.code});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message, super.code});
}

/// 400/422 with optional per-field messages.
final class ValidationFailure extends Failure {
  const ValidationFailure({super.message, super.code, this.fieldErrors = const {}});

  final Map<String, List<String>> fieldErrors;
}

final class ConflictFailure extends Failure {
  const ConflictFailure({super.message, super.code});
}

final class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure({super.message, this.retryAfterSeconds});

  final int? retryAfterSeconds;
}

final class ServerFailure extends Failure {
  const ServerFailure({super.message, super.code});
}

final class UnknownFailure extends Failure {
  const UnknownFailure({super.message});
}

/// Backend error codes the admin app reacts to.
abstract final class ApiErrorCodes {
  static const accountInactive = 'ACCOUNT_INACTIVE';
}

/// Turns anything thrown by Dio into a [Failure]. The backend always answers
/// `{ error: { message, code, errors? } }`.
Failure mapToFailure(Object error) {
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
      return const UnknownFailure(message: 'cancelled');
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
    case DioExceptionType.badResponse:
      break;
  }

  final response = error.response;
  if (response == null) return const NetworkFailure();

  final body = response.data;
  String? message;
  String? code;
  var fieldErrors = <String, List<String>>{};
  if (body is Map<String, dynamic>) {
    final envelope = body['error'];
    if (envelope is Map<String, dynamic>) {
      final rawMessage = envelope['message'];
      final rawCode = envelope['code'];
      message = rawMessage is String ? rawMessage : null;
      code = rawCode is String ? rawCode : null;
      final rawErrors = envelope['errors'];
      if (rawErrors is Map<String, dynamic>) {
        fieldErrors = {
          for (final entry in rawErrors.entries)
            entry.key: [
              if (entry.value is List<dynamic>)
                for (final item in entry.value as List<dynamic>) item.toString(),
            ],
        };
      }
    }
  }

  switch (response.statusCode) {
    case 400:
    case 422:
      return ValidationFailure(message: message, code: code, fieldErrors: fieldErrors);
    case 401:
      return UnauthorizedFailure(message: message, code: code);
    case 403:
      return ForbiddenFailure(message: message, code: code);
    case 404:
      return NotFoundFailure(message: message, code: code);
    case 409:
      return ConflictFailure(message: message, code: code);
    case 429:
      return TooManyRequestsFailure(
        message: message,
        retryAfterSeconds: int.tryParse(response.headers.value('retry-after') ?? ''),
      );
    case final int status when status >= 500:
      return ServerFailure(message: message, code: code);
    default:
      return UnknownFailure(message: message);
  }
}
