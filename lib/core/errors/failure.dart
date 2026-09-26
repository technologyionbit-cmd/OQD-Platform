/// Application-level failure types.
///
/// Every repository returns [Result], never a raw exception, so the
/// presentation layer only ever has typed failures to branch on and can
/// never leak a raw backend/network exception message to the UI.
sealed class Failure implements Exception {
  const Failure({this.message});

  /// Optional backend-provided message, already safe to display
  /// (validated/sanitized at the mapping boundary). May be null, in which
  /// case the UI should fall back to a localized generic message.
  final String? message;
}

/// No network connection, or the request could not reach the server.
final class NetworkFailure extends Failure {
  const NetworkFailure({super.message});
}

/// The request timed out.
final class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message});
}

/// 401 — access token missing/invalid/expired and refresh failed.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message});
}

/// 403 — authenticated but not allowed to perform this action.
/// The backend is the authority here; this only exists to drive UI feedback.
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message});
}

/// 404 — resource not found.
final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message});
}

/// 422 / field-level validation errors returned by the backend.
final class ValidationFailure extends Failure {
  const ValidationFailure({super.message, this.fieldErrors = const {}});

  final Map<String, List<String>> fieldErrors;
}

/// 5xx — server-side error.
final class ServerFailure extends Failure {
  const ServerFailure({super.message, this.statusCode});

  final int? statusCode;
}

/// Local cache/storage read or write failed.
final class CacheFailure extends Failure {
  const CacheFailure({super.message});
}

/// Anything that doesn't map to a more specific failure above.
final class UnknownFailure extends Failure {
  const UnknownFailure({super.message});
}
