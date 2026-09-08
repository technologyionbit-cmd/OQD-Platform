import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/messages/domain/entities/message.dart';
import 'package:aqd_ionbit/features/messages/domain/entities/message_type.dart';

/// Wire-level contract for the written-chat thread, mirroring
/// `ConsultationsRemoteDataSource` — throws a `Failure` on any failure
/// path, never a raw exception.
abstract interface class MessagesRemoteDataSource {
  Future<List<Message>> getMessages(String consultationId);

  Future<Message> sendMessage({
    required String consultationId,
    required String senderId,
    required UserRole senderRole,
    required MessageType type,
    String text,
    String? attachmentUrl,
  });

  Future<void> markAllRead({required String consultationId, required UserRole viewerRole});

  Future<Map<String, int>> getUnreadCounts({required UserRole viewerRole});
}
