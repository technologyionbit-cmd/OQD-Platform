import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/ai_conversation.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/contract_analysis.dart';

abstract interface class AiRepository {
  Future<Result<List<AiConversation>>> getConversations();

  Future<Result<AiConversation>> getConversationById(String id);

  /// Appends the user's message and a mock assistant reply, creating a new
  /// conversation first when [conversationId] is null.
  Future<Result<AiConversation>> sendMessage({required String text, String? conversationId});

  Future<Result<void>> clearConversation(String id);

  Future<Result<List<ContractAnalysis>>> getAnalyses();

  Future<Result<ContractAnalysis>> getAnalysisById(String id);

  Future<Result<ContractAnalysis>> analyzeDocument({required String documentTitle, String? sourceDocumentId});
}
