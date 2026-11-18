import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/utils/latin_digits_formatter.dart';

void main() {
  test('converts Arabic-Indic and Persian digits to Latin and leaves the rest', () {
    expect(LatinDigitsFormatter.convert('٠٧٩١٢٣٤٥٦٧'), '0791234567');
    expect(LatinDigitsFormatter.convert('۱۲۳'), '123');
    expect(LatinDigitsFormatter.convert('محمد ٥ abc 7'), 'محمد 5 abc 7');
  });

  test('keeps the caret when converting', () {
    const formatter = LatinDigitsFormatter();
    final result = formatter.formatEditUpdate(TextEditingValue.empty, const TextEditingValue(text: '٧٩', selection: TextSelection.collapsed(offset: 2)));
    expect(result.text, '79');
    expect(result.selection.baseOffset, 2);
  });
}
