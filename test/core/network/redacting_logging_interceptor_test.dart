import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/network/interceptors/redacting_logging_interceptor.dart';

void main() {
  Object? redact(Object? data) => RedactingLoggingInterceptor.redact(data);

  test('redacts every password/token variant regardless of casing', () {
    final result = redact({
      'password': 'a',
      'newPassword': 'b',
      'currentPassword': 'c',
      'refreshToken': 'd',
      'AccessToken': 'e',
      'email': 'user@aqd.test',
    });

    expect(result, {
      'password': '***',
      'newPassword': '***',
      'currentPassword': '***',
      'refreshToken': '***',
      'AccessToken': '***',
      'email': 'user@aqd.test',
    });
  });

  test('redacts an OTP sent as "code" but not unrelated *Code fields', () {
    expect(redact({'code': '123456', 'countryCode': 'JO'}), {'code': '***', 'countryCode': 'JO'});
  });

  test('redacts inside nested maps and lists', () {
    expect(
      redact({
        'items': [
          {'cardNumber': '4111', 'label': 'visa'},
        ],
        'nested': {'otp': '1'},
      }),
      {
        'items': [
          {'cardNumber': '***', 'label': 'visa'},
        ],
        'nested': {'otp': '***'},
      },
    );
  });

  test('leaves non-map payloads untouched', () {
    expect(redact('plain'), 'plain');
    expect(redact(null), isNull);
  });
}
