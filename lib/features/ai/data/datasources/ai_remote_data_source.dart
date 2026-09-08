import 'package:aqd_ionbit/features/ai/domain/entities/ai_conversation.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/contract_analysis.dart';

/// Wire-level contract for the AI feature. Mirrors
/// `ContractsRemoteDataSource` — throws a [Failure] on any failure path,
/// never a raw exception. Swapping this for a real LLM-backed API later is
/// a same-signature, same-callers change; nothing above this layer knows
/// the replies are canned.
abstract interface class AiRemoteDataSource {
  Future<List<AiConversation>> getConversations();

  Future<AiConversation> getConversationById(String id);

  Future<AiConversation> sendMessage({required String text, String? conversationId});

  Future<void> clearConversation(String id);

  Future<List<ContractAnalysis>> getAnalyses();

  Future<ContractAnalysis> getAnalysisById(String id);

  Future<ContractAnalysis> analyzeDocument({required String documentTitle, String? sourceDocumentId});
}
