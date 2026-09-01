import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/documents/data/repositories/documents_repository_impl.dart';
import 'package:aqd_ionbit/features/documents/domain/entities/document.dart';
import 'package:aqd_ionbit/features/documents/domain/repositories/documents_repository.dart';

class DocumentsController extends AsyncNotifier<List<Document>> {
  late final DocumentsRepository _repository;

  @override
  FutureOr<List<Document>> build() async {
    _repository = ref.watch(documentsRepositoryProvider);
    final result = await _repository.getDocuments();
    return result.fold((failure) => throw failure, (documents) => documents);
  }

  Future<void> refresh() async {
    final result = await _repository.getDocuments();
    state = result.fold((failure) => AsyncError(failure, StackTrace.current), (documents) => AsyncData(documents));
  }

  /// Called from the contracts feature once a contract is generated — see
  /// `ContractDraftController.generate`.
  Future<void> addFromGeneratedContract({required String contractId, required String title}) async {
    final result = await _repository.addGeneratedContractDocument(contractId: contractId, title: title);
    if (result.isSuccess) await refresh();
  }
}

final documentsControllerProvider = AsyncNotifierProvider<DocumentsController, List<Document>>(DocumentsController.new);
