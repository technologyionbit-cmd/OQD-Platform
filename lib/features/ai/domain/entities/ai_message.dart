import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_message.freezed.dart';

@freezed
abstract class AiMessage with _$AiMessage {
  const factory AiMessage({
    required String id,
    required String text,
    required bool isFromUser,
    required DateTime sentAt,
    @Default(false) bool isError,
  }) = _AiMessage;
}
