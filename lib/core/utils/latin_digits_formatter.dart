import 'package:flutter/services.dart';

/// Converts Arabic-Indic (٠-٩) and Persian (۰-۹) digits to 0-9 as the user
/// types or pastes, so phone numbers, codes and amounts are always stored
/// and sent with Latin digits. Same length in and out, so the caret stays put.
class LatinDigitsFormatter extends TextInputFormatter {
  const LatinDigitsFormatter();

  static String convert(String input) {
    final out = StringBuffer();
    for (final unit in input.codeUnits) {
      if (unit >= 0x0660 && unit <= 0x0669) {
        out.writeCharCode(unit - 0x0660 + 0x30);
      } else if (unit >= 0x06F0 && unit <= 0x06F9) {
        out.writeCharCode(unit - 0x06F0 + 0x30);
      } else if (unit == 0x066B) {
        out.write('.'); // Arabic decimal separator
      } else {
        out.writeCharCode(unit);
      }
    }
    return out.toString();
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final converted = convert(newValue.text);
    return converted == newValue.text ? newValue : newValue.copyWith(text: converted);
  }
}
