import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/documents/data/datasources/documents_data_source_provider.dart';
import 'package:aqd_ionbit/features/documents/data/datasources/documents_remote_data_source.dart';
import 'package:aqd_ionbit/features/documents/domain/entities/document.dart';
import 'package:aqd_ionbit/features/documents/domain/repositories/documents_repository.dart';

class DocumentsRepositoryImpl implements DocumentsRepository {
  DocumentsRepositoryImpl({required DocumentsRemoteDataSource remoteDataSource, ApiErrorMapper errorMapper = const ApiErrorMapper()})
    : _remote = remoteDataSource,
      _errorMapper = errorMapper;

  final DocumentsRemoteDataSource _remote;
  final ApiErrorMapper _errorMapper;

  @override
  Future<Result<List<Document>>> getDocuments() => _errorMapper.capture(_remote.getDocuments);

  @override
  Future<Result<Document>> addGeneratedContractDocument({required String contractId, required String title}) {
    return _errorMapper.capture(() => _remote.addGeneratedContractDocument(contractId: contractId, title: title));
  }

  @override
  Future<Result<Document>> uploadDocument({required String title}) => _errorMapper.capture(() => _remote.uploadDocument(title: title));

  @override
  Future<Result<Document>> renameDocument({required String id, required String newTitle}) {
    return _errorMapper.capture(() => _remote.renameDocument(id: id, newTitle: newTitle));
  }

  @override
  Future<Result<void>> deleteDocument(String id) => _errorMapper.capture(() => _remote.deleteDocument(id));
}

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  return DocumentsRepositoryImpl(remoteDataSource: ref.watch(documentsRemoteDataSourceProvider));
});
