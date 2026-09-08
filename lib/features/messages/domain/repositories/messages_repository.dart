import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/messages/domain/entities/message.dart';
import 'package:aqd_ionbit/features/messages/domain/entities/message_type.dart';

/// Contract for the written-chat message thread — scoped by consultation
/// ID, independent of `ConsultationsRepository`'s own lightweight
/// `sendMessage` (which still backs the old `ConsultationMessage` thread on
/// `ConsultationDetailsScreen`). A real backend later swaps in behind
/// [getUnreadCounts] too, so the per-card badge on `ConsultationsListScreen`
/// never has to change.
abstract interface class MessagesRepository {
  /// The full transcript for [consultationId], oldest first.
  Future<Result<List<Message>>> getMessages(String consultationId);

  /// Appends a new message and returns it as stored (id/sentAt assigned by
  /// the data source).
  Future<Result<Message>> sendMessage({
    required String consultationId,
    required String senderId,
    required UserRole senderRole,
    required MessageType type,
    String text,
    String? attachmentUrl,
  });

  /// Marks every message in [consultationId] not authored by [viewerRole]
  /// as read by that viewer — called when `ChatRoomScreen` comes into the
  /// foreground for that consultation.
  Future<Result<void>> markAllRead({required String consultationId, required UserRole viewerRole});

  /// Unread-message count per consultation ID, from [viewerRole]'s point of
  /// view — backs the badge on `ConsultationsListScreen`'s cards.
  Future<Result<Map<String, int>>> getUnreadCounts({required UserRole viewerRole});
}
