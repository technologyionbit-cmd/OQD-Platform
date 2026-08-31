/// Presentation-layer validation only — this makes forms responsive and
/// friendly, it is NOT a security boundary. The backend re-validates and
/// remains authoritative; see `errorInvalidCredentials` / [ValidationFailure]
/// for how server-side validation errors are surfaced back into these same
/// forms.
class Validators {
  const Validators._();

  static final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phoneRegExp = RegExp(r'^\+?[0-9]{8,15}$');

  /// Returns a validation message key (to be localized by the caller) or
  /// null if valid. Keeping this a pure function (no BuildContext) makes it
  /// trivially unit-testable.
  static bool isRequired(String? value) => value != null && value.trim().isNotEmpty;

  static bool isValidEmail(String? value) => value != null && _emailRegExp.hasMatch(value.trim());

  static bool isPasswordLongEnough(String? value) => value != null && value.length >= 8;

  static bool isValidPhone(String? value) => value != null && _phoneRegExp.hasMatch(value.trim().replaceAll(' ', ''));
}
