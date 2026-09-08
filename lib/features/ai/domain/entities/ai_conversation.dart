import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/ai/domain/entities/ai_message.dart';

part 'ai_conversation.freezed.dart';

@freezed
abstract class AiConversation with _$AiConversation {
  const factory AiConversation({
    required String id,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(<AiMessage>[]) List<AiMessage> messages,
  }) = _AiConversation;
}
