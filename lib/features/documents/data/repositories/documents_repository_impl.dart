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
  Future<Result<List<Document>>> getDocuments() => _guard(_remote.getDocuments);

  @override
  Future<Result<Document>> addGeneratedContractDocument({required String contractId, required String title}) {
    return _guard(() => _remote.addGeneratedContractDocument(contractId: contractId, title: title));
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } catch (e) {
      return Result.failure(_errorMapper.map(e));
    }
  }
}

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  return DocumentsRepositoryImpl(remoteDataSource: ref.watch(documentsRemoteDataSourceProvider));
});
