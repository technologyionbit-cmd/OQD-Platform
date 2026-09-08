import 'package:aqd_ionbit/features/documents/domain/entities/document.dart';

abstract interface class DocumentsRemoteDataSource {
  Future<List<Document>> getDocuments();

  Future<Document> addGeneratedContractDocument({required String contractId, required String title});

  Future<Document> uploadDocument({required String title});

  Future<Document> renameDocument({required String id, required String newTitle});

  Future<void> deleteDocument(String id);
}
