import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/features/auth/presentation/widgets/password_strength_meter.dart';

void main() {
  test('breaking a required rule is weak', () {
    expect(passwordStrengthOf('abc123'), PasswordStrength.weak); // too short
    expect(passwordStrengthOf('abcdefgh'), PasswordStrength.weak); // no digit
    expect(passwordStrengthOf('12345678'), PasswordStrength.weak); // no letter
  });

  test('meeting the rules is good', () {
    expect(passwordStrengthOf('abcd1234'), PasswordStrength.good);
  });

  test('extra length or variety on top of the rules is strong', () {
    expect(passwordStrengthOf('Abcd1234'), PasswordStrength.good); // one extra only
    expect(passwordStrengthOf('Abcd1234!'), PasswordStrength.strong); // mixed case + symbol
    expect(passwordStrengthOf('abcdefgh1234'), PasswordStrength.good); // long only
    expect(passwordStrengthOf('abcdefgh1234!'), PasswordStrength.strong); // long + symbol
  });
}
