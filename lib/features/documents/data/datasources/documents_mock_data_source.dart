import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/features/documents/data/datasources/documents_remote_data_source.dart';
import 'package:aqd_ionbit/features/documents/domain/entities/document.dart';
import 'package:aqd_ionbit/features/documents/domain/entities/document_source_type.dart';

/// Temporary, isolated stand-in for the real backend — no documents/vault
/// API is available yet. Seeded with one demo document so the vault isn't
/// empty on first run; every contract the client actually generates during
/// the session is added for real via [addGeneratedContractDocument].
class DocumentsMockDataSource implements DocumentsRemoteDataSource {
  final List<Document> _documents = [
    Document(
      id: 'd_seed_1',
      title: 'عقد خدمات - شركة الأفق',
      sourceType: DocumentSourceType.generatedContract,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      sizeLabel: '340 KB',
      contractId: 'c_seed_1',
    ),
  ];

  @override
  Future<List<Document>> getDocuments() async {
    await _simulateLatency();
    final sorted = List<Document>.of(_documents)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Future<Document> addGeneratedContractDocument({required String contractId, required String title}) async {
    await _simulateLatency();
    final document = Document(
      id: 'd_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      sourceType: DocumentSourceType.generatedContract,
      createdAt: DateTime.now(),
      sizeLabel: '${180 + contractId.length * 3} KB',
      contractId: contractId,
    );
    _documents.insert(0, document);
    return document;
  }

  @override
  Future<Document> uploadDocument({required String title}) async {
    await _simulateLatency();
    final document = Document(
      id: 'd_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      sourceType: DocumentSourceType.uploaded,
      createdAt: DateTime.now(),
      sizeLabel: '${120 + title.length * 5} KB',
    );
    _documents.insert(0, document);
    return document;
  }

  @override
  Future<Document> renameDocument({required String id, required String newTitle}) async {
    await _simulateLatency();
    final index = _documents.indexWhere((d) => d.id == id);
    if (index == -1) throw const NotFoundFailure();
    final updated = _documents[index].copyWith(title: newTitle);
    _documents[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteDocument(String id) async {
    await _simulateLatency();
    _documents.removeWhere((d) => d.id == id);
  }

  Future<void> _simulateLatency() => Future.delayed(const Duration(milliseconds: 400));
}
