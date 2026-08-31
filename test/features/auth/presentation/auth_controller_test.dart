import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/domain/repositories/auth_repository.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenManager extends Mock implements TokenManager {}

void main() {
  const user = AuthUser(id: 'u1', fullName: 'Test User', email: 'test@aqd.test', role: UserRole.client);
  const tokens = AuthTokens(accessToken: 'access', refreshToken: 'refresh');

  late MockAuthRepository repository;
  late MockTokenManager tokenManager;
  late ProviderContainer container;

  setUp(() {
    repository = MockAuthRepository();
    tokenManager = MockTokenManager();

    when(() => tokenManager.loadFromStorage()).thenAnswer((_) async => null);
    when(() => tokenManager.current).thenReturn(null);

    // ProviderScope overrides: the controller is exercised against a fake
    // repository/token manager, never a real one — this is what makes it
    // testable without a backend or platform channels.
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository), tokenManagerProvider.overrideWithValue(tokenManager)],
    );
    addTearDown(container.dispose);
  });

  test('resolves to unauthenticated (null) when there is no stored session', () async {
    final result = await container.read(authControllerProvider.future);
    expect(result, isNull);
  });

  test('login() moves state to the authenticated user on success', () async {
    await container.read(authControllerProvider.future);
    when(
      () => repository.login(email: any(named: 'email'), password: any(named: 'password')),
    ).thenAnswer((_) async => const Result.success((user: user, tokens: tokens)));

    final result = await container.read(authControllerProvider.notifier).login(email: user.email, password: 'Password123');

    expect(result.isSuccess, isTrue);
    expect(container.read(authControllerProvider).value, user);
  });

  test('login() reports the Failure and leaves state unauthenticated on bad credentials', () async {
    await container.read(authControllerProvider.future);
    when(
      () => repository.login(email: any(named: 'email'), password: any(named: 'password')),
    ).thenAnswer((_) async => const Result.failure(UnauthorizedFailure()));

    final result = await container.read(authControllerProvider.notifier).login(email: user.email, password: 'wrong');

    expect(result.isFailure, isTrue);
    expect(container.read(authControllerProvider).value, isNull);
  });

  test('logout() clears the authenticated user', () async {
    await container.read(authControllerProvider.future);
    when(
      () => repository.login(email: any(named: 'email'), password: any(named: 'password')),
    ).thenAnswer((_) async => const Result.success((user: user, tokens: tokens)));
    await container.read(authControllerProvider.notifier).login(email: user.email, password: 'Password123');
    when(() => repository.logout()).thenAnswer((_) async {});

    await container.read(authControllerProvider.notifier).logout();

    expect(container.read(authControllerProvider).value, isNull);
  });
}
