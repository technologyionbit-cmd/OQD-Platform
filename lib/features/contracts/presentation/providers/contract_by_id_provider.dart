import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/contracts/data/repositories/contracts_repository_impl.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';

/// `.family` because the details screen is parameterized by whichever
/// contract id is in the route — a natural fit here, unlike forcing one in
/// earlier for the sake of demonstrating the pattern.
final contractByIdProvider = FutureProvider.family<Contract, String>((ref, id) async {
  final repository = ref.watch(contractsRepositoryProvider);
  final result = await repository.getContractById(id);
  return result.fold((failure) => throw failure, (contract) => contract);
});
