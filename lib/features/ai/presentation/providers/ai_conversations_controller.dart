import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/ai_conversation.dart';
import 'package:aqd_ionbit/features/ai/domain/repositories/ai_repository.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/current_user_id_provider.dart';

class AiConversationsController extends AsyncNotifier<List<AiConversation>> {
  AiRepository get _repository => ref.read(aiRepositoryProvider);

  @override
  FutureOr<List<AiConversation>> build() async {
    ref.watch(aiRepositoryProvider);
    if (ref.watch(currentUserIdProvider) == null) return const []; // Signed out: no one's data.
    final result = await _repository.getConversations();
    return result.fold((failure) => throw failure, (conversations) => conversations);
  }

  Future<void> refresh() async {
    final result = await _repository.getConversations();
    state = result.fold((failure) => AsyncError(failure, StackTrace.current), AsyncData.new);
  }

  Future<Result<AiConversation>> sendMessage({required String text, String? conversationId}) async {
    final result = await _repository.sendMessage(text: text, conversationId: conversationId);
    if (result.isSuccess) await refresh();
    return result;
  }

  Future<void> clearConversation(String id) async {
    final result = await _repository.clearConversation(id);
    if (result.isSuccess) await refresh();
  }
}

final aiConversationsControllerProvider = AsyncNotifierProvider<AiConversationsController, List<AiConversation>>(
  AiConversationsController.new,
);

final aiConversationByIdProvider = Provider.autoDispose.family<AiConversation?, String>(
  (ref, id) => ref.watch(aiConversationsControllerProvider).value?.where((c) => c.id == id).firstOrNull,
);
