import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';

/// The generic, context-free wording for a [Failure]. Screens with a more
/// specific meaning for a failure (e.g. login turning 401 into "wrong email
/// or password") match those cases first and fall back to this.
extension FailureMessage on Failure {
  String localizedMessage(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.errorNetwork,
    TimeoutFailure() => l10n.errorTimeout,
    ServerFailure() => l10n.errorServer,
    _ => l10n.errorGeneric,
  };
}
