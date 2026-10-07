import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/contract_analysis.dart';
import 'package:aqd_ionbit/features/ai/domain/repositories/ai_repository.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/current_user_id_provider.dart';

class AiAnalysesController extends AsyncNotifier<List<ContractAnalysis>> {
  AiRepository get _repository => ref.read(aiRepositoryProvider);

  @override
  FutureOr<List<ContractAnalysis>> build() async {
    ref.watch(aiRepositoryProvider);
    if (ref.watch(currentUserIdProvider) == null) return const []; // Signed out: no one's data.
    final result = await _repository.getAnalyses();
    return result.fold((failure) => throw failure, (analyses) => analyses);
  }

  Future<void> refresh() async {
    final result = await _repository.getAnalyses();
    state = result.fold((failure) => AsyncError(failure, StackTrace.current), AsyncData.new);
  }

  Future<Result<ContractAnalysis>> analyzeDocument({required String documentTitle, String? sourceDocumentId}) async {
    final result = await _repository.analyzeDocument(documentTitle: documentTitle, sourceDocumentId: sourceDocumentId);
    if (result.isSuccess) await refresh();
    return result;
  }
}

final aiAnalysesControllerProvider = AsyncNotifierProvider<AiAnalysesController, List<ContractAnalysis>>(AiAnalysesController.new);

final aiAnalysisByIdProvider = Provider.autoDispose.family<ContractAnalysis?, String>(
  (ref, id) => ref.watch(aiAnalysesControllerProvider).value?.where((a) => a.id == id).firstOrNull,
);
