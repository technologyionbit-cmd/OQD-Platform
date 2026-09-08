import 'package:aqd_ionbit/features/messages/domain/entities/message.dart';

/// [ChatController]'s state — the transcript plus the handful of
/// UI-relevant transients (typing indicator, in-flight send) that don't
/// belong on [Message] itself. A plain class, not `@freezed`: small enough
/// that hand-writing `copyWith` avoids a codegen part file for three
/// fields.
class ChatState {
  const ChatState({this.messages = const <Message>[], this.isLawyerTyping = false, this.isSending = false});

  final List<Message> messages;

  /// True only for the ~1-3s mock-delay window before a simulated lawyer
  /// reply lands — the screen driving that simulation is responsible for
  /// flipping this back off, including on dispose, so it can never get
  /// stuck visible.
  final bool isLawyerTyping;

  /// Guards against a rapid double-tap on send re-submitting the same
  /// message twice.
  final bool isSending;

  ChatState copyWith({List<Message>? messages, bool? isLawyerTyping, bool? isSending}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLawyerTyping: isLawyerTyping ?? this.isLawyerTyping,
      isSending: isSending ?? this.isSending,
    );
  }
}
