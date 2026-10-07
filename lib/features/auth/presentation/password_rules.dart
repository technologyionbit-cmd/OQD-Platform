import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';

/// The first rule a new [password] breaks, in the user's language, or null.
/// Same rules, same order, as the server's password check — used wherever
/// the user picks a password (register, reset).
String? newPasswordError(String password, AppLocalizations l10n) {
  if (!Validators.isPasswordLongEnough(password)) return l10n.validationPasswordTooShort;
  if (!Validators.isPasswordWithinByteLimit(password)) return l10n.validationPasswordTooLong;
  if (!Validators.hasLetterAndDigit(password)) return l10n.validationPasswordNeedsLetterAndDigit;
  return null;
}
