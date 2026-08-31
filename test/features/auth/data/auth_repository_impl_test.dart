import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockTokenManager extends Mock implements TokenManager {}

void main() {
  const user = AuthUser(id: 'u1', fullName: 'Test User', email: 'test@aqd.test', role: UserRole.client);
  const tokens = AuthTokens(accessToken: 'access', refreshToken: 'refresh');

  late MockAuthRemoteDataSource remote;
  late MockTokenManager tokenManager;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const AuthTokens(accessToken: 'fallback', refreshToken: 'fallback'));
  });

  setUp(() {
    remote = MockAuthRemoteDataSource();
    tokenManager = MockTokenManager();
    repository = AuthRepositoryImpl(remoteDataSource: remote, tokenManager: tokenManager);
  });

  group('login', () {
    test('returns success and persists the returned tokens', () async {
      when(
        () => remote.login(email: any(named: 'email'), password: any(named: 'password')),
      ).thenAnswer((_) async => (user: user, tokens: tokens));
      when(() => tokenManager.save(tokens)).thenAnswer((_) async {});

      final result = await repository.login(email: 'test@aqd.test', password: 'Password123');

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.user, user);
      verify(() => tokenManager.save(tokens)).called(1);
    });

    test('maps a thrown Failure to Result.failure and never touches TokenManager', () async {
      when(
        () => remote.login(email: any(named: 'email'), password: any(named: 'password')),
      ).thenThrow(const UnauthorizedFailure());

      final result = await repository.login(email: 'test@aqd.test', password: 'wrong');

      expect(result.isFailure, isTrue);
      verifyNever(() => tokenManager.save(any()));
    });
  });

  group('register', () {
    const request = RegisterRequest.individual(
      fullName: 'New User',
      phone: '+962700000000',
      email: 'new@aqd.test',
      password: 'Password123',
    );

    test('returns success and persists the returned tokens', () async {
      when(() => remote.register(request)).thenAnswer((_) async => (user: user, tokens: tokens));
      when(() => tokenManager.save(tokens)).thenAnswer((_) async {});

      final result = await repository.register(request);

      expect(result.isSuccess, isTrue);
      verify(() => tokenManager.save(tokens)).called(1);
    });

    test('maps a duplicate-email Failure to Result.failure', () async {
      when(() => remote.register(request)).thenThrow(
        const ValidationFailure(fieldErrors: {
          'email': ['taken'],
        }),
      );

      final result = await repository.register(request);

      expect(result.isFailure, isTrue);
      verifyNever(() => tokenManager.save(any()));
    });
  });

  group('logout', () {
    test('clears the local session even if the remote call throws', () async {
      when(() => tokenManager.current).thenReturn(tokens);
      when(() => remote.logout(any())).thenThrow(Exception('network down'));
      when(() => tokenManager.clear()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => tokenManager.clear()).called(1);
    });
  });
}
