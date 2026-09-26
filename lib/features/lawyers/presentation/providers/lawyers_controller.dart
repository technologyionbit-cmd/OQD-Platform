import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/lawyers/data/repositories/lawyers_repository_impl.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/domain/repositories/lawyers_repository.dart';

/// The marketplace's full lawyer list — screens filter/search over this
/// client-side rather than each filter combination being its own fetch.
class LawyersController extends AsyncNotifier<List<LawyerProfile>> {
  late final LawyersRepository _repository;

  @override
  FutureOr<List<LawyerProfile>> build() async {
    _repository = ref.watch(lawyersRepositoryProvider);
    final result = await _repository.getLawyers();
    return result.fold((failure) => throw failure, (lawyers) => lawyers);
  }

  Future<void> refresh() async {
    final result = await _repository.getLawyers();
    state = result.fold((failure) => AsyncError(failure, StackTrace.current), AsyncData.new);
  }
}

final lawyersControllerProvider = AsyncNotifierProvider<LawyersController, List<LawyerProfile>>(LawyersController.new);
