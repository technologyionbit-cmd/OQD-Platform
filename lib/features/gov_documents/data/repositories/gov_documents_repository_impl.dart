import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/gov_documents/data/datasources/gov_documents_data_source_provider.dart';
import 'package:aqd_ionbit/features/gov_documents/data/datasources/gov_documents_remote_data_source.dart';
import 'package:aqd_ionbit/features/gov_documents/domain/entities/gov_procedure.dart';
import 'package:aqd_ionbit/features/gov_documents/domain/repositories/gov_documents_repository.dart';

class GovDocumentsRepositoryImpl implements GovDocumentsRepository {
  GovDocumentsRepositoryImpl({required GovDocumentsRemoteDataSource remoteDataSource, ApiErrorMapper errorMapper = const ApiErrorMapper()})
    : _remote = remoteDataSource,
      _errorMapper = errorMapper;

  final GovDocumentsRemoteDataSource _remote;
  final ApiErrorMapper _errorMapper;

  @override
  Future<Result<List<GovProcedure>>> getGovProcedures({required String locale}) =>
      _errorMapper.capture(() => _remote.getGovProcedures(locale: locale));

  @override
  Future<Result<GovProcedureProgress>> getProgress(GovProcedureType type) => _errorMapper.capture(() => _remote.getProgress(type));

  @override
  Future<Result<GovProcedureProgress>> toggleDocument(GovProcedureType type, String documentId) =>
      _errorMapper.capture(() => _remote.updateProgress(type, toggleDocumentId: documentId));

  @override
  Future<Result<GovProcedureProgress>> start(GovProcedureType type) => _errorMapper.capture(() => _remote.updateProgress(type, start: true));
}

final govDocumentsRepositoryProvider = Provider<GovDocumentsRepository>((ref) {
  return GovDocumentsRepositoryImpl(remoteDataSource: ref.watch(govDocumentsRemoteDataSourceProvider));
});
