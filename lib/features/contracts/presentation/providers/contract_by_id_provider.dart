import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/auth/presentation/providers/current_user_id_provider.dart';
import 'package:aqd_ionbit/features/contracts/data/repositories/contracts_repository_impl.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';

/// `.family` because the details screen is parameterized by whichever
/// contract id is in the route — a natural fit here, unlike forcing one in
/// earlier for the sake of demonstrating the pattern.
final contractByIdProvider = FutureProvider.family<Contract, String>((ref, id) async {
  ref.watch(currentUserIdProvider); // Another account must not reuse a cached contract.
  final repository = ref.watch(contractsRepositoryProvider);
  final result = await repository.getContractById(id);
  return result.fold((failure) => throw failure, (contract) => contract);
});
