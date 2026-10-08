/// Application-level failure types.
///
/// Every repository returns [Result], never a raw exception, so the
/// presentation layer only ever has typed failures to branch on and can
/// never leak a raw backend/network exception message to the UI.
sealed class Failure implements Exception {
  const Failure({this.message, this.code});

  /// Optional backend-provided message — English, for logs and debugging.
  /// Not for display: the UI renders a localized message chosen from the
  /// failure type and [code] (see `FailureMessage`).
  final String? message;

  /// The backend's machine-readable error code (`error.code` in the API
  /// envelope — see [ApiErrorCodes]), when the failure came from the API.
  final String? code;
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
  const UnauthorizedFailure({super.message, super.code});
}

/// 403 — authenticated but not allowed to perform this action.
/// The backend is the authority here; this only exists to drive UI feedback.
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message, super.code});
}

/// 404 — resource not found.
final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message, super.code});
}

/// 422 / field-level validation errors returned by the backend.
final class ValidationFailure extends Failure {
  const ValidationFailure({super.message, super.code, this.fieldErrors = const {}});

  final Map<String, List<String>> fieldErrors;
}

/// 429 — too many attempts. [retryAfter] comes from the `Retry-After`
/// header when the server sent one.
final class RateLimitedFailure extends Failure {
  const RateLimitedFailure({super.message, super.code, this.retryAfter});

  final Duration? retryAfter;
}

/// 5xx (or an unexpected status) — server-side error.
final class ServerFailure extends Failure {
  const ServerFailure({super.message, super.code, this.statusCode});

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

/// Error codes the backend sends in `error.code` that the app reacts to
/// specifically. Mirrors `ApiErrorCode` in backend/src/common/errors.
abstract final class ApiErrorCodes {
  /// A 422 whose `errors` are plain per-field rule failures.
  static const validationError = 'VALIDATION_ERROR';
  static const accountInactive = 'ACCOUNT_INACTIVE';
  static const tooManyRequests = 'TOO_MANY_REQUESTS';
  static const emailAlreadyRegistered = 'EMAIL_ALREADY_REGISTERED';
  static const phoneAlreadyRegistered = 'PHONE_ALREADY_REGISTERED';
  static const commercialRegistrationTaken = 'COMMERCIAL_REGISTRATION_TAKEN';
  static const barLicenseTaken = 'BAR_LICENSE_TAKEN';
  static const termsVersionOutdated = 'TERMS_VERSION_OUTDATED';
  static const invalidVerificationCode = 'INVALID_VERIFICATION_CODE';
  static const verificationCodeLocked = 'VERIFICATION_CODE_LOCKED';
  static const phoneNotVerified = 'PHONE_NOT_VERIFIED';
  static const contractStatusConflict = 'CONTRACT_STATUS_CONFLICT';
}
