import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/network/auth_session_ports.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_session.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockTokenManager extends Mock implements TokenManager {}

void main() {
  const user = AuthUser(id: 'u1', fullName: 'Test User', email: 'test@aqd.test', role: UserRole.client, emailVerified: true);
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
      acceptTerms: true,
      termsVersion: '2026-09-28',
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

    test('passes the stored refresh token to the remote call', () async {
      when(() => tokenManager.current).thenReturn(tokens);
      when(() => remote.logout(any())).thenAnswer((_) async {});
      when(() => tokenManager.clear()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => remote.logout('refresh')).called(1);
    });
  });

  group('refreshSession', () {
    test('persists the rotated tokens on success', () async {
      const rotated = AuthTokens(accessToken: 'access2', refreshToken: 'refresh2');
      when(() => tokenManager.current).thenReturn(tokens);
      when(() => remote.refreshToken('refresh')).thenAnswer((_) async => rotated);
      when(() => tokenManager.save(rotated)).thenAnswer((_) async {});

      final outcome = await repository.refreshSession();

      expect(outcome, isA<RefreshSucceeded>().having((o) => o.tokens, 'tokens', rotated));
      verify(() => tokenManager.save(rotated)).called(1);
    });

    test('is rejected without a network call when no refresh token is held', () async {
      when(() => tokenManager.current).thenReturn(null);

      expect(await repository.refreshSession(), isA<RefreshRejected>());
      verifyNever(() => remote.refreshToken(any()));
    });

    final refusals = <Failure>[
      const UnauthorizedFailure(),
      const ForbiddenFailure(),
      const ValidationFailure(),
      const ServerFailure(statusCode: 400),
    ];
    for (final failure in refusals) {
      test('is rejected when the server refuses the token (${failure.runtimeType})', () async {
        when(() => tokenManager.current).thenReturn(tokens);
        when(() => remote.refreshToken(any())).thenThrow(failure);

        expect(await repository.refreshSession(), isA<RefreshRejected>());
      });
    }

    final transient = <Failure>[
      const NetworkFailure(),
      const TimeoutFailure(),
      const ServerFailure(statusCode: 503),
      const RateLimitedFailure(retryAfter: Duration(minutes: 1)),
    ];
    for (final failure in transient) {
      test('is unavailable, not rejected, on a transient failure (${failure.runtimeType})', () async {
        when(() => tokenManager.current).thenReturn(tokens);
        when(() => remote.refreshToken(any())).thenThrow(failure);

        expect(await repository.refreshSession(), isA<RefreshUnavailable>());
      });
    }
  });

  group('restoreSession', () {
    test('resolves to no user when nothing is stored', () async {
      when(() => tokenManager.loadFromStorage()).thenAnswer((_) async => null);

      final result = await repository.restoreSession();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isNull);
      verifyNever(() => remote.currentUser());
    });

    test('resolves to the user when the stored session is still valid', () async {
      when(() => tokenManager.loadFromStorage()).thenAnswer((_) async => tokens);
      when(() => tokenManager.current).thenReturn(tokens);
      when(() => remote.currentUser()).thenAnswer((_) async => user);

      final result = await repository.restoreSession();

      expect(result.valueOrNull, user);
    });

    test('clears the stored tokens when the server no longer accepts them', () async {
      when(() => tokenManager.loadFromStorage()).thenAnswer((_) async => tokens);
      when(() => tokenManager.current).thenReturn(tokens);
      when(() => remote.currentUser()).thenThrow(const UnauthorizedFailure());
      when(() => tokenManager.clear()).thenAnswer((_) async {});

      final result = await repository.restoreSession();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isNull);
      verify(() => tokenManager.clear()).called(1);
    });

    test('keeps the stored tokens and reports the failure when the server is unreachable', () async {
      when(() => tokenManager.loadFromStorage()).thenAnswer((_) async => tokens);
      when(() => tokenManager.current).thenReturn(tokens);
      when(() => remote.currentUser()).thenThrow(const NetworkFailure());

      final result = await repository.restoreSession();

      expect(result.fold((f) => f, (_) => null), isA<NetworkFailure>());
      verifyNever(() => tokenManager.clear());
    });
  });

  group('currentUser', () {
    test('short-circuits to UnauthorizedFailure when no token is stored', () async {
      when(() => tokenManager.current).thenReturn(null);

      final result = await repository.currentUser();

      expect(result.isFailure, isTrue);
      verifyNever(() => remote.currentUser());
    });
  });

  group('changePassword', () {
    test('maps a thrown ValidationFailure to Result.failure', () async {
      when(
        () => remote.changePassword(currentPassword: any(named: 'currentPassword'), newPassword: any(named: 'newPassword')),
      ).thenThrow(const ValidationFailure(fieldErrors: {
        'currentPassword': ['Current password is incorrect.'],
      }));

      final result = await repository.changePassword(currentPassword: 'wrong', newPassword: 'Password123');

      expect(result.isFailure, isTrue);
    });
  });

  group('listSessions', () {
    test('returns the sessions from the remote source', () async {
      final sessions = [
        AuthSession(id: 's1', createdAt: DateTime(2026), isCurrent: true),
        AuthSession(id: 's2', createdAt: DateTime(2026), isCurrent: false),
      ];
      when(() => remote.listSessions()).thenAnswer((_) async => sessions);

      final result = await repository.listSessions();

      expect(result.valueOrNull, sessions);
    });
  });
}
