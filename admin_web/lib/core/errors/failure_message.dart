import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/core/localization/generated/app_localizations.dart';

/// The localized text for a [Failure]. The only place failures become words.
String failureMessage(AppLocalizations l10n, Object error) {
  final failure = error is Failure ? error : mapToFailure(error);
  return switch (failure) {
    NetworkFailure() => l10n.errorNetwork,
    TimeoutFailure() => l10n.errorTimeout,
    UnauthorizedFailure() => l10n.errorUnauthorized,
    ForbiddenFailure() => l10n.errorForbidden,
    NotFoundFailure() => l10n.errorNotFound,
    ValidationFailure() => l10n.errorValidation,
    ConflictFailure() => l10n.errorConflict,
    TooManyRequestsFailure() => l10n.errorTooManyRequests,
    ServerFailure() => l10n.errorServer,
    UnknownFailure() => l10n.errorUnknown,
  };
}
