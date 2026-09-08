import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/messages/domain/entities/message_type.dart';

part 'message.freezed.dart';

/// A single message within a consultation's chat thread — the one real,
/// live message model in the app (rendered by `ChatRoomScreen`).
/// `consultations/domain/entities/consultation_message.dart` is an older,
/// now UI-disconnected thread kept only for its own (already-tested) mock
/// data layer; nothing displays it anymore.
@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String consultationId,
    required String senderId,
    required UserRole senderRole,
    required MessageType type,
    @Default('') String text,
    String? attachmentUrl,
    required DateTime sentAt,
    DateTime? readAt,
  }) = _Message;
}
