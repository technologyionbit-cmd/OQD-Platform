import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/features/auth/data/datasources/auth_wire.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';

void main() {
  group('registerBody', () {
    test('individual → accountType individual with name/phone', () {
      final body = AuthWire.registerBody(
        const RegisterRequest.individual(
          fullName: 'Ahmad',
          phone: '0790000000',
          email: 'a@test.com',
          password: 'Password123',
          acceptTerms: true,
          termsVersion: 'v1',
        ),
      );
      expect(body, {
        'accountType': 'individual',
        'fullName': 'Ahmad',
        'phone': '0790000000',
        'email': 'a@test.com',
        'password': 'Password123',
        'acceptTerms': true,
        'termsVersion': 'v1',
      });
    });

    test('company → carries the commercial registration number', () {
      final body = AuthWire.registerBody(
        const RegisterRequest.company(
          companyName: 'Rowad',
          commercialRegistrationNumber: 'CR-1',
          email: 'c@test.com',
          phone: '0791111111',
          password: 'Password123',
          acceptTerms: true,
          termsVersion: 'v1',
        ),
      );
      expect(body['accountType'], 'company');
      expect(body['companyName'], 'Rowad');
      expect(body['commercialRegistrationNumber'], 'CR-1');
      expect(body.containsKey('fullName'), isFalse);
    });

    test('lawyer → carries bar license + specialty', () {
      final body = AuthWire.registerBody(
        const RegisterRequest.lawyer(
          fullName: 'Sara',
          barLicenseNumber: 'BAR-1',
          mainSpecialty: 'commercial',
          email: 'l@test.com',
          phone: '0792222222',
          password: 'Password123',
          acceptTerms: true,
          termsVersion: 'v1',
        ),
      );
      expect(body['accountType'], 'lawyer');
      expect(body['barLicenseNumber'], 'BAR-1');
      expect(body['mainSpecialty'], 'commercial');
    });
  });

  group('response parsing', () {
    test('session() reads user + tokens out of the data envelope', () {
      final result = AuthWire.session({
        'data': {
          'user': {'id': 'u1', 'fullName': 'Ahmad', 'email': 'a@test.com', 'role': 'lawyer', 'emailVerified': false},
          'tokens': {'accessToken': 'access', 'refreshToken': 'refresh'},
        },
      });
      expect(result.user.role, UserRole.lawyer);
      expect(result.user.id, 'u1');
      expect(result.user.emailVerified, isFalse);
      expect(result.tokens.accessToken, 'access');
      expect(result.tokens.refreshToken, 'refresh');
    });

    test('user() throws on an unknown role rather than defaulting', () {
      expect(
        () => AuthWire.user({'id': 'u1', 'fullName': 'X', 'email': 'x@test.com', 'role': 'admin', 'emailVerified': false}),
        throwsArgumentError,
      );
    });

    test('user() reads emailVerified and fails loudly when it is missing', () {
      final verified = AuthWire.user({'id': 'u1', 'fullName': 'X', 'email': 'x@test.com', 'role': 'client', 'emailVerified': true});
      expect(verified.emailVerified, isTrue);

      expect(
        () => AuthWire.user({'id': 'u1', 'fullName': 'X', 'email': 'x@test.com', 'role': 'client'}),
        throwsA(isA<TypeError>()),
      );
    });

    test('sessionSummary() maps the current flag and nullable fields', () {
      final session = AuthWire.sessionSummary({
        'id': 's1',
        'deviceLabel': 'curl/8',
        'ipAddress': null,
        'createdAt': '2026-09-10T10:00:00.000Z',
        'lastUsedAt': null,
        'current': true,
      });
      expect(session.id, 's1');
      expect(session.deviceLabel, 'curl/8');
      expect(session.ipAddress, isNull);
      expect(session.lastUsedAt, isNull);
      expect(session.isCurrent, isTrue);
    });
  });
}
