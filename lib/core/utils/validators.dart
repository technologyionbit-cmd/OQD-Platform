/// Presentation-layer validation only — this makes forms responsive and
/// friendly, it is NOT a security boundary. The backend re-validates and
/// remains authoritative; see `errorInvalidCredentials` / [ValidationFailure]
/// for how server-side validation errors are surfaced back into these same
/// forms.
class Validators {
  const Validators._();

  static final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phoneRegExp = RegExp(r'^\+?[0-9]{8,15}$');
  static final _cardNumberRegExp = RegExp(r'^[0-9]{12,19}$');
  static final _expiryRegExp = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
  static final _cvvRegExp = RegExp(r'^[0-9]{3,4}$');
  static final _last4RegExp = RegExp(r'^[0-9]{4}$');

  /// Returns a validation message key (to be localized by the caller) or
  /// null if valid. Keeping this a pure function (no BuildContext) makes it
  /// trivially unit-testable.
  static bool isRequired(String? value) => value != null && value.trim().isNotEmpty;

  static bool isValidEmail(String? value) => value != null && _emailRegExp.hasMatch(value.trim());

  static bool isPasswordLongEnough(String? value) => value != null && value.length >= 8;

  static bool isValidPhone(String? value) => value != null && _phoneRegExp.hasMatch(value.trim().replaceAll(' ', ''));

  static bool isValidCardNumber(String? value) => value != null && _cardNumberRegExp.hasMatch(value.trim().replaceAll(' ', ''));

  /// Expects `MM/YY`, and requires the month to not already be in the past.
  static bool isValidExpiry(String? value, {DateTime? now}) {
    if (value == null) return false;
    final match = _expiryRegExp.firstMatch(value.trim());
    if (match == null) return false;
    final month = int.parse(match.group(1)!);
    final year = 2000 + int.parse(match.group(2)!);
    final current = now ?? DateTime.now();
    final expiryEnd = DateTime(year, month + 1);
    return !expiryEnd.isBefore(DateTime(current.year, current.month));
  }

  static bool isValidCvv(String? value) => value != null && _cvvRegExp.hasMatch(value.trim());

  static bool isValidLast4(String? value) => value != null && _last4RegExp.hasMatch(value.trim());
}
