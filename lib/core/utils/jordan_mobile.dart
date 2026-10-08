/// Jordanian mobile numbers (Zain 79, Orange 77, Umniah 78) — the account
/// identifier for sign-in and every texted code. Mirrors
/// `normalizeJordanMobile` in backend/src/auth/dto/phone.rules.ts, which
/// stays authoritative.
abstract final class JordanMobile {
  static final _allowedChars = RegExp(r'^[\d\s()+-]+$');
  static final _nonDigits = RegExp(r'\D');
  static final _shape = RegExp(r'^(?:00962|962|0)?(7[789][0-9]{7})$');

  /// `07X XXX XXXX`, `7XXXXXXXX`, `9627XXXXXXXX`, `009627XXXXXXXX` or
  /// `+9627XXXXXXXX` -> `+9627XXXXXXXX`; null for anything else.
  static String? normalize(String raw) {
    if (!_allowedChars.hasMatch(raw.trim())) return null;
    final local = _shape.firstMatch(raw.replaceAll(_nonDigits, ''))?.group(1);
    return local == null ? null : '+962$local';
  }

  /// `+9627XXXXXXXX` -> `07XXXXXXXX`, the spelling people read and type.
  /// Anything else is returned unchanged.
  static String display(String phone) {
    final normalized = normalize(phone);
    return normalized == null ? phone : '0${normalized.substring(4)}';
  }
}
