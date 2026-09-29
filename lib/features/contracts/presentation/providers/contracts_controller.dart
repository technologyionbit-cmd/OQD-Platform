import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/current_user_id_provider.dart';
import 'package:aqd_ionbit/features/contracts/data/repositories/contracts_repository_impl.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';
import 'package:aqd_ionbit/features/contracts/domain/repositories/contracts_repository.dart';

/// The client's contract list — `AsyncLoading` while fetching,
/// `AsyncData(contracts)` once loaded. Screens watch this instead of
/// calling the repository themselves.
class ContractsController extends AsyncNotifier<List<Contract>> {
  ContractsRepository get _repository => ref.read(contractsRepositoryProvider);

  @override
  FutureOr<List<Contract>> build() async {
    ref.watch(contractsRepositoryProvider);
    if (ref.watch(currentUserIdProvider) == null) return const []; // Signed out: no one's data.
    final result = await _repository.getContracts();
    return result.fold((failure) => throw failure, (contracts) => contracts);
  }

  /// Re-fetches without clearing the currently-shown list first — a brief
  /// full-screen loading flash on every refresh would be worse UX than
  /// just swapping the data in once it arrives.
  Future<void> refresh() async {
    final result = await _repository.getContracts();
    state = result.fold((failure) => AsyncError(failure, StackTrace.current), AsyncData.new);
  }

  Future<Result<void>> delete(String id) async {
    final result = await _repository.deleteContract(id);
    if (result.isSuccess) await refresh();
    return result;
  }

  Future<Result<Contract>> sign(String id) async {
    final result = await _repository.signContract(id);
    if (result.isSuccess) await refresh();
    return result;
  }
}

final contractsControllerProvider = AsyncNotifierProvider<ContractsController, List<Contract>>(ContractsController.new);
