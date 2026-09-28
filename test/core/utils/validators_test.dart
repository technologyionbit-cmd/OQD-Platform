import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/utils/validators.dart';

void main() {
  group('password rules mirror the server', () {
    test('needs 8 characters', () {
      expect(Validators.isPasswordLongEnough('abc1234'), isFalse);
      expect(Validators.isPasswordLongEnough('abcd1234'), isTrue);
    });

    test('needs a Latin letter and a digit', () {
      expect(Validators.hasLetterAndDigit('abcdefgh'), isFalse);
      expect(Validators.hasLetterAndDigit('12345678'), isFalse);
      expect(Validators.hasLetterAndDigit('كلمةسر1234'), isFalse);
      expect(Validators.hasLetterAndDigit('abcd1234'), isTrue);
    });

    test('allows at most 72 UTF-8 bytes, not 72 characters', () {
      final exactly72 = 'a1${'ب' * 35}'; // 2 + 35 × 2 bytes
      final over72 = 'a1${'ب' * 36}'; // 38 characters, 74 bytes

      expect(Validators.isPasswordWithinByteLimit(exactly72), isTrue);
      expect(Validators.isPasswordWithinByteLimit(over72), isFalse);
      expect(Validators.isPasswordWithinByteLimit('a1${'x' * 71}'), isFalse);
    });
  });

  test('field limits match the backend DTOs', () {
    expect(Validators.nameMaxLength, 120);
    expect(Validators.companyNameMaxLength, 160);
    expect(Validators.registryNumberMaxLength, 60);
    expect(Validators.emailMaxLength, 254);
  });
}
