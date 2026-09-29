import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/domain/repositories/auth_repository.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/contracts/data/repositories/contracts_repository_impl.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_category.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_status.dart';
import 'package:aqd_ionbit/features/contracts/domain/repositories/contracts_repository.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contracts_controller.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockContractsRepository extends Mock implements ContractsRepository {}

const _alice = AuthUser(id: 'u_alice', fullName: 'Alice', email: 'alice@aqd.test', role: UserRole.client, emailVerified: true);
const _bob = AuthUser(id: 'u_bob', fullName: 'Bob', email: 'bob@aqd.test', role: UserRole.client, emailVerified: true);
const _tokens = AuthTokens(accessToken: 'access', refreshToken: 'refresh');

Contract _contractOf(String owner) => Contract(
  id: 'c_$owner',
  title: '$owner contract',
  category: ContractCategory.other,
  status: ContractStatus.draft,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  parties: const [],
  fieldValues: const {},
  templateId: 'other',
  generatedContent: '',
);

void main() {
  test('signing out and in as someone else never shows the previous account\'s data', () async {
    final auth = _MockAuthRepository();
    final contracts = _MockContractsRepository();
    when(auth.restoreSession).thenAnswer((_) async => const Result.success(null));
    when(auth.logout).thenAnswer((_) async {});
    for (final user in [_alice, _bob]) {
      when(() => auth.login(email: user.email, password: any(named: 'password'))).thenAnswer((_) async => Result.success((user: user, tokens: _tokens)));
    }

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        contractsRepositoryProvider.overrideWithValue(contracts),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(contractsControllerProvider, (_, _) {});
    addTearDown(sub.close);
    await container.read(authControllerProvider.future);
    final session = container.read(authControllerProvider.notifier);

    when(contracts.getContracts).thenAnswer((_) async => Result.success([_contractOf('alice')]));
    await session.login(email: _alice.email, password: 'Password123');
    expect(await container.read(contractsControllerProvider.future), [_contractOf('alice')]);

    await session.logout();
    expect(await container.read(contractsControllerProvider.future), isEmpty);

    when(contracts.getContracts).thenAnswer((_) async => Result.success([_contractOf('bob')]));
    await session.login(email: _bob.email, password: 'Password123');
    expect(await container.read(contractsControllerProvider.future), [_contractOf('bob')]);
  });
}
