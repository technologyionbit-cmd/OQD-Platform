import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/ai/data/datasources/ai_data_source_provider.dart';
import 'package:aqd_ionbit/features/ai/data/datasources/ai_remote_data_source.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/ai_conversation.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/contract_analysis.dart';
import 'package:aqd_ionbit/features/ai/domain/repositories/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl({required AiRemoteDataSource remoteDataSource, ApiErrorMapper errorMapper = const ApiErrorMapper()})
    : _remote = remoteDataSource,
      _errorMapper = errorMapper;

  final AiRemoteDataSource _remote;
  final ApiErrorMapper _errorMapper;

  @override
  Future<Result<List<AiConversation>>> getConversations() => _guard(_remote.getConversations);

  @override
  Future<Result<AiConversation>> getConversationById(String id) => _guard(() => _remote.getConversationById(id));

  @override
  Future<Result<AiConversation>> sendMessage({required String text, String? conversationId}) {
    return _guard(() => _remote.sendMessage(text: text, conversationId: conversationId));
  }

  @override
  Future<Result<void>> clearConversation(String id) => _guard(() => _remote.clearConversation(id));

  @override
  Future<Result<List<ContractAnalysis>>> getAnalyses() => _guard(_remote.getAnalyses);

  @override
  Future<Result<ContractAnalysis>> getAnalysisById(String id) => _guard(() => _remote.getAnalysisById(id));

  @override
  Future<Result<ContractAnalysis>> analyzeDocument({required String documentTitle, String? sourceDocumentId}) {
    return _guard(() => _remote.analyzeDocument(documentTitle: documentTitle, sourceDocumentId: sourceDocumentId));
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } catch (e) {
      return Result.failure(_errorMapper.map(e));
    }
  }
}

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl(remoteDataSource: ref.watch(aiRemoteDataSourceProvider));
});
