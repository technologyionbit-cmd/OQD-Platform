import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/documents/domain/entities/document.dart';

abstract interface class DocumentsRepository {
  Future<Result<List<Document>>> getDocuments();

  /// Registers a document for a contract that was just generated —
  /// called from the contracts feature's save flow so a newly generated
  /// contract actually shows up in the vault, not just conceptually.
  Future<Result<Document>> addGeneratedContractDocument({required String contractId, required String title});

  /// Represents picking/uploading a file — there's no real file picker in
  /// this phase (see the documents screen's upload sheet), so this just
  /// registers a [DocumentSourceType.uploaded] entry from a title.
  Future<Result<Document>> uploadDocument({required String title});

  Future<Result<Document>> renameDocument({required String id, required String newTitle});

  Future<Result<void>> deleteDocument(String id);
}
