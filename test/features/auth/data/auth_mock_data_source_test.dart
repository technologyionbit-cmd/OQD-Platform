import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/features/auth/data/datasources/auth_mock_data_source.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';

void main() {
  late AuthMockDataSource dataSource;

  setUp(() => dataSource = AuthMockDataSource());

  group('login', () {
    test('succeeds for a seeded demo account with the right password', () async {
      final result = await dataSource.login(email: 'client@aqd.test', password: 'Password123');
      expect(result.user.role, UserRole.client);
    });

    test('throws UnauthorizedFailure for a wrong password', () {
      expect(() => dataSource.login(email: 'client@aqd.test', password: 'wrong'), throwsA(isA<UnauthorizedFailure>()));
    });
  });

  group('register', () {
    test('creates a new account and returns a session for each account type', () async {
      final individual = await dataSource.register(
        const RegisterRequest.individual(fullName: 'Layla', phone: '+962700000001', email: 'layla@aqd.test', password: 'Password123'),
      );
      expect(individual.user.role, UserRole.client);

      final company = await dataSource.register(
        const RegisterRequest.company(
          companyName: 'Acme Legal',
          commercialRegistrationNumber: '12345',
          email: 'acme@aqd.test',
          phone: '+962700000002',
          password: 'Password123',
        ),
      );
      expect(company.user.role, UserRole.company);
      expect(company.user.fullName, 'Acme Legal');

      final lawyer = await dataSource.register(
        const RegisterRequest.lawyer(
          fullName: 'Yousef',
          barLicenseNumber: 'JBA-1',
          mainSpecialty: 'Commercial law',
          email: 'yousef@aqd.test',
          phone: '+962700000003',
          password: 'Password123',
        ),
      );
      expect(lawyer.user.role, UserRole.lawyer);
    });

    test('rejects an email that is already registered', () {
      expect(
        () => dataSource.register(
          const RegisterRequest.individual(fullName: 'Dup', phone: '+962700000004', email: 'client@aqd.test', password: 'Password123'),
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('the newly registered account can immediately log in', () async {
      await dataSource.register(
        const RegisterRequest.individual(fullName: 'Sara', phone: '+962700000005', email: 'sara@aqd.test', password: 'MyPass123'),
      );

      final result = await dataSource.login(email: 'sara@aqd.test', password: 'MyPass123');
      expect(result.user.fullName, 'Sara');
    });
  });

  group('resetPassword', () {
    test('rejects an incorrect code', () {
      expect(
        () => dataSource.resetPassword(destination: 'client@aqd.test', code: '0000', newPassword: 'NewPass123'),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('updates the password for a known account so the new password logs in', () async {
      await dataSource.resetPassword(destination: 'client@aqd.test', code: '1234', newPassword: 'NewPass123');

      final result = await dataSource.login(email: 'client@aqd.test', password: 'NewPass123');
      expect(result.user.role, UserRole.client);
    });
  });
}
