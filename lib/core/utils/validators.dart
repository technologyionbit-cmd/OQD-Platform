import 'dart:convert';

import 'package:aqd_ionbit/core/utils/jordan_mobile.dart';

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

  // Password rules and field lengths mirror the backend DTOs
  // (backend/src/auth/dto) so the form rejects what the server would.
  // Text fields enforce the lengths as their `maxLength`.
  static const passwordMinLength = 8;

  /// bcrypt reads only the first 72 bytes; the server refuses longer
  /// passwords. Counted in UTF-8 bytes — an Arabic letter is 2 bytes.
  static const passwordMaxBytes = 72;
  static const nameMaxLength = 120;
  static const companyNameMaxLength = 160;
  static const registryNumberMaxLength = 60;
  static const emailMaxLength = 254;

  static final _letterRegExp = RegExp('[A-Za-z]');
  static final _digitRegExp = RegExp('[0-9]');

  static bool isPasswordLongEnough(String? value) => value != null && value.length >= passwordMinLength;

  /// At least one Latin letter and one digit — the server's rule.
  static bool hasLetterAndDigit(String? value) => value != null && _letterRegExp.hasMatch(value) && _digitRegExp.hasMatch(value);

  static bool isPasswordWithinByteLimit(String? value) => value != null && utf8.encode(value).length <= passwordMaxBytes;

  /// Any phone number (e.g. a contract party's). Account numbers use
  /// [isValidJordanMobile].
  static bool isValidPhone(String? value) => value != null && _phoneRegExp.hasMatch(value.trim().replaceAll(' ', ''));

  /// The account phone: a Jordanian mobile in any common spelling.
  static bool isValidJordanMobile(String? value) => value != null && JordanMobile.normalize(value) != null;

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
