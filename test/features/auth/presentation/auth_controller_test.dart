import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/network/auth_session_ports.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/phone_verification_prompt.dart';
import '../../../support/test_doubles.dart';

void main() {
  const user = AuthUser(id: 'u1', fullName: 'Test User', email: 'test@aqd.test', phone: '+962791234567', role: UserRole.client, phoneVerified: true);
  const tokens = AuthTokens(accessToken: 'access', refreshToken: 'refresh');

  late MockAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockAuthRepository();
    when(() => repository.restoreSession()).thenAnswer((_) async => const Result.success(null));

    // ProviderScope overrides: the controller is exercised against a fake
    // repository, never a real one — this is what makes it testable
    // without a backend or platform channels.
    container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);
  });

  group('session restore on startup', () {
    test('resolves to unauthenticated (null) when there is no stored session', () async {
      final result = await container.read(authControllerProvider.future);
      expect(result, isNull);
    });

    test('resolves to the stored user when the session is still valid', () async {
      when(() => repository.restoreSession()).thenAnswer((_) async => const Result.success(user));

      expect(await container.read(authControllerProvider.future), user);
    });

    test('surfaces an unreachable server as an error instead of signing the user out', () async {
      when(() => repository.restoreSession()).thenAnswer((_) async => const Result.failure(NetworkFailure()));

      await expectLater(container.read(authControllerProvider.future), throwsA(isA<NetworkFailure>()));
      final state = container.read(authControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.value, isNull);
    });

    test('retrying after an error restores the session once the server is reachable', () async {
      when(() => repository.restoreSession()).thenAnswer((_) async => const Result.failure(NetworkFailure()));
      await expectLater(container.read(authControllerProvider.future), throwsA(isA<NetworkFailure>()));

      when(() => repository.restoreSession()).thenAnswer((_) async => const Result.success(user));
      container.invalidate(authControllerProvider);

      expect(await container.read(authControllerProvider.future), user);
    });

    test('wires the token refresher to the repository', () async {
      when(() => repository.refreshSession()).thenAnswer((_) async => const RefreshSucceeded(tokens));
      await container.read(authControllerProvider.future);

      final outcome = await container.read(tokenRefresherProvider).call();

      expect(outcome, isA<RefreshSucceeded>());
      verify(() => repository.refreshSession()).called(1);
    });

    test('an expired session clears the stored tokens and signs the user out', () async {
      when(() => repository.restoreSession()).thenAnswer((_) async => const Result.success(user));
      when(() => repository.clearLocalSession()).thenAnswer((_) async {});
      await container.read(authControllerProvider.future);

      container.read(sessionExpiredNotifierProvider).notify();
      await pumpEventQueue();

      verify(() => repository.clearLocalSession()).called(1);
      expect(container.read(authControllerProvider).value, isNull);
    });
  });

  test('login() moves state to the authenticated user on success', () async {
    await container.read(authControllerProvider.future);
    when(
      () => repository.login(phone: any(named: 'phone'), password: any(named: 'password')),
    ).thenAnswer((_) async => const Result.success((user: user, tokens: tokens)));

    final result = await container.read(authControllerProvider.notifier).login(phone: user.phone!, password: 'Password123');

    expect(result.isSuccess, isTrue);
    expect(container.read(authControllerProvider).value, user);
  });

  test('login() reports the Failure and leaves state unauthenticated on bad credentials', () async {
    await container.read(authControllerProvider.future);
    when(
      () => repository.login(phone: any(named: 'phone'), password: any(named: 'password')),
    ).thenAnswer((_) async => const Result.failure(UnauthorizedFailure()));

    final result = await container.read(authControllerProvider.notifier).login(phone: user.phone!, password: 'wrong');

    expect(result.isFailure, isTrue);
    expect(container.read(authControllerProvider).value, isNull);
  });

  test('logout() clears the authenticated user', () async {
    await container.read(authControllerProvider.future);
    when(
      () => repository.login(phone: any(named: 'phone'), password: any(named: 'password')),
    ).thenAnswer((_) async => const Result.success((user: user, tokens: tokens)));
    await container.read(authControllerProvider.notifier).login(phone: user.phone!, password: 'Password123');
    when(() => repository.logout()).thenAnswer((_) async {});

    await container.read(authControllerProvider.notifier).logout();

    expect(container.read(authControllerProvider).value, isNull);
  });

  group('phone verification', () {
    const unverified = AuthUser(id: 'u2', fullName: 'New User', email: 'new@aqd.test', phone: '+962791234567', role: UserRole.client, phoneVerified: false);
    const request = RegisterRequest.individual(
      fullName: 'New User',
      phone: '0791234567',
      email: 'new@aqd.test',
      password: 'Password123',
      acceptTerms: true,
      termsVersion: 'v1',
    );

    test('a new unverified account turns the verify prompt on', () async {
      when(() => repository.register(request)).thenAnswer((_) async => const Result.success((user: unverified, tokens: tokens)));
      await container.read(authControllerProvider.future);

      await container.read(authControllerProvider.notifier).register(request);

      expect(container.read(phoneVerificationPromptProvider), isTrue);
      expect(container.read(authControllerProvider).value, unverified);
    });

    test('verifying replaces the user and turns the prompt off', () async {
      const verified = AuthUser(id: 'u2', fullName: 'New User', email: 'new@aqd.test', phone: '+962791234567', role: UserRole.client, phoneVerified: true);
      when(() => repository.verifyPhone(code: '123456')).thenAnswer((_) async => const Result.success(verified));
      await container.read(authControllerProvider.future);
      container.read(phoneVerificationPromptProvider.notifier).show();

      await container.read(authControllerProvider.notifier).verifyPhone('123456');

      expect(container.read(authControllerProvider).value, verified);
      expect(container.read(phoneVerificationPromptProvider), isFalse);
    });

    test('a failed verification keeps the user and the prompt', () async {
      when(() => repository.restoreSession()).thenAnswer((_) async => const Result.success(unverified));
      when(() => repository.verifyPhone(code: '000000')).thenAnswer(
        (_) async => const Result.failure(ValidationFailure(code: ApiErrorCodes.invalidVerificationCode)),
      );
      await container.read(authControllerProvider.future);
      container.read(phoneVerificationPromptProvider.notifier).show();

      final result = await container.read(authControllerProvider.notifier).verifyPhone('000000');

      expect(result, isA<ResultFailure<AuthUser>>());
      expect(container.read(authControllerProvider).value, unverified);
      expect(container.read(phoneVerificationPromptProvider), isTrue);
    });

    test('logging out turns the prompt off', () async {
      when(() => repository.logout()).thenAnswer((_) async {});
      await container.read(authControllerProvider.future);
      container.read(phoneVerificationPromptProvider.notifier).show();

      await container.read(authControllerProvider.notifier).logout();

      expect(container.read(phoneVerificationPromptProvider), isFalse);
    });
  });
}
