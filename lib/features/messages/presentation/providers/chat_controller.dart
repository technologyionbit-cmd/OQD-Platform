import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/current_user_id_provider.dart';
import 'package:aqd_ionbit/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:aqd_ionbit/features/messages/domain/entities/message.dart';
import 'package:aqd_ionbit/features/messages/domain/entities/message_type.dart';
import 'package:aqd_ionbit/features/messages/domain/repositories/messages_repository.dart';
import 'package:aqd_ionbit/features/messages/presentation/providers/chat_state.dart';
import 'package:aqd_ionbit/features/messages/presentation/providers/chat_unread_controller.dart';

const _notReadyFailure = UnknownFailure(message: 'Chat not loaded yet.');

/// Drives one consultation's written-chat transcript: load, send
/// (text/image/file), mark-read, and the typing-indicator flag a mock
/// lawyer-reply simulation toggles. The simulation's actual delay/`Timer`
/// work lives in `ChatRoomScreen` itself (guaranteeing it is cancelled in
/// the screen's own `dispose()`) — this controller only exposes the state
/// transitions the screen drives it through, plus the plain data
/// operations (send/read) any client of the chat could call.
class ChatController extends AsyncNotifier<ChatState> {
  ChatController(this.consultationId);

  final String consultationId;
  MessagesRepository get _repository => ref.read(messagesRepositoryProvider);

  @override
  FutureOr<ChatState> build() async {
    ref.watch(messagesRepositoryProvider);
    ref.watch(currentUserIdProvider);
    final result = await _repository.getMessages(consultationId);
    return result.fold((failure) => throw failure, (messages) => ChatState(messages: messages));
  }

  Future<Result<Message>> sendText({required String senderId, required UserRole senderRole, required String text}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return Future.value(const Result.failure(ValidationFailure(message: 'Message text must not be empty.')));
    }
    return _send(senderId: senderId, senderRole: senderRole, type: MessageType.text, text: trimmed);
  }

  Future<Result<Message>> sendImage({required String senderId, required UserRole senderRole, required String attachmentUrl}) {
    return _send(senderId: senderId, senderRole: senderRole, type: MessageType.image, attachmentUrl: attachmentUrl);
  }

  Future<Result<Message>> sendFile({
    required String senderId,
    required UserRole senderRole,
    required String fileName,
    required String attachmentUrl,
  }) {
    return _send(senderId: senderId, senderRole: senderRole, type: MessageType.file, text: fileName, attachmentUrl: attachmentUrl);
  }

  Future<Result<Message>> _send({
    required String senderId,
    required UserRole senderRole,
    required MessageType type,
    String text = '',
    String? attachmentUrl,
  }) async {
    final current = state.value;
    if (current == null || current.isSending) return const Result.failure(_notReadyFailure);

    state = AsyncData(current.copyWith(isSending: true));
    final result = await _repository.sendMessage(
      consultationId: consultationId,
      senderId: senderId,
      senderRole: senderRole,
      type: type,
      text: text,
      attachmentUrl: attachmentUrl,
    );
    final base = state.value ?? current;
    result.fold(
      (failure) => state = AsyncData(base.copyWith(isSending: false)),
      (message) => state = AsyncData(base.copyWith(messages: [...base.messages, message], isSending: false)),
    );
    ref.invalidate(chatUnreadCountsProvider);
    return result;
  }

  /// Appends an already-built lawyer reply (constructed by the screen from
  /// a localized canned pool, since l10n needs a `BuildContext`) and clears
  /// the typing indicator in the same state update so the UI never renders
  /// a frame with both the indicator and the new message.
  void appendLawyerReply(Message reply) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(messages: [...current.messages, reply], isLawyerTyping: false));
    ref.invalidate(chatUnreadCountsProvider);
  }

  void setLawyerTyping(bool typing) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(isLawyerTyping: typing));
  }

  Future<void> markRead(UserRole viewerRole) async {
    final current = state.value;
    if (current == null) return;
    final now = DateTime.now();
    state = AsyncData(
      current.copyWith(
        messages: [
          for (final message in current.messages)
            if (message.senderRole != viewerRole && message.readAt == null) message.copyWith(readAt: now) else message,
        ],
      ),
    );
    await _repository.markAllRead(consultationId: consultationId, viewerRole: viewerRole);
    ref.invalidate(chatUnreadCountsProvider);
  }
}

final chatControllerProvider = AsyncNotifierProvider.family<ChatController, ChatState, String>(ChatController.new);
