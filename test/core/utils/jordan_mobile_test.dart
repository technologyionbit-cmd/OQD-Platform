import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/utils/jordan_mobile.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';

void main() {
  group('JordanMobile mirrors the server normalization', () {
    for (final raw in ['0791234567', '079 123 4567', '(079) 123-4567', '791234567', '962791234567', '00962791234567', '+962791234567']) {
      test('$raw -> +962791234567', () {
        expect(JordanMobile.normalize(raw), '+962791234567');
        expect(Validators.isValidJordanMobile(raw), isTrue);
      });
    }

    for (final raw in ['', 'user@aqd.test', '0761234567', '065000000', '07912345678', '+966501234567']) {
      test('rejects "$raw"', () {
        expect(JordanMobile.normalize(raw), isNull);
        expect(Validators.isValidJordanMobile(raw), isFalse);
      });
    }
  });

  test('displays a stored number the local way', () {
    expect(JordanMobile.display('+962781234567'), '0781234567');
    expect(JordanMobile.display('not a number'), 'not a number');
  });
}
