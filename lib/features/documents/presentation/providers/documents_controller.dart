import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/current_user_id_provider.dart';
import 'package:aqd_ionbit/features/documents/data/repositories/documents_repository_impl.dart';
import 'package:aqd_ionbit/features/documents/domain/entities/document.dart';
import 'package:aqd_ionbit/features/documents/domain/repositories/documents_repository.dart';

class DocumentsController extends AsyncNotifier<List<Document>> {
  DocumentsRepository get _repository => ref.read(documentsRepositoryProvider);

  @override
  FutureOr<List<Document>> build() async {
    ref.watch(documentsRepositoryProvider);
    if (ref.watch(currentUserIdProvider) == null) return const []; // Signed out: no one's data.
    final result = await _repository.getDocuments();
    return result.fold((failure) => throw failure, (documents) => documents);
  }

  Future<void> refresh() async {
    final result = await _repository.getDocuments();
    state = result.fold((failure) => AsyncError(failure, StackTrace.current), AsyncData.new);
  }

  /// Called from the contracts feature once a contract is generated — see
  /// `ContractDraftController.generate`.
  Future<void> addFromGeneratedContract({required String contractId, required String title}) async {
    final result = await _repository.addGeneratedContractDocument(contractId: contractId, title: title);
    if (result.isSuccess) await refresh();
  }

  Future<Result<Document>> upload(String title) async {
    final result = await _repository.uploadDocument(title: title);
    if (result.isSuccess) await refresh();
    return result;
  }

  Future<Result<Document>> rename({required String id, required String newTitle}) async {
    final result = await _repository.renameDocument(id: id, newTitle: newTitle);
    if (result.isSuccess) await refresh();
    return result;
  }

  Future<Result<void>> delete(String id) async {
    final result = await _repository.deleteDocument(id);
    if (result.isSuccess) await refresh();
    return result;
  }
}

final documentsControllerProvider = AsyncNotifierProvider<DocumentsController, List<Document>>(DocumentsController.new);
