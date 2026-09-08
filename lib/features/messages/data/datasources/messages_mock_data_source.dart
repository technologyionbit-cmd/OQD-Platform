import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/messages/data/datasources/messages_remote_data_source.dart';
import 'package:aqd_ionbit/features/messages/domain/entities/message.dart';
import 'package:aqd_ionbit/features/messages/domain/entities/message_type.dart';

/// No real backend/WebSocket involved — the whole written-chat transcript
/// lives in memory for the app session, keyed by consultation ID. Seeded
/// against the same demo identities `AuthMockDataSource` uses
/// ([kDemoClientUserId] / [kDemoLawyerUserId]) so a message's `senderRole`
/// lines up with whichever demo account is signed in, and against
/// `cons_seed_2`/`cons_seed_6` from `ConsultationsMockDataSource` so opening
/// those consultations' chat rooms has real history to show.
/// Sending a message whose trimmed text exactly equals this reserved
/// trigger simulates a network failure the *first* time it's sent for a
/// given consultation — deterministic, no randomness — so the app's
/// failed-send/retry UI has a real, reachable path to demonstrate and test
/// against. Sending the identical text again for the same consultation
/// (i.e. tapping "Retry") succeeds normally, just like a real transient
/// blip would recover on retry.
const kMockChatFailureTrigger = '#networkerror';

class MessagesMockDataSource implements MessagesRemoteDataSource {
  static const clientId = kDemoClientUserId;
  static const lawyerId = kDemoLawyerUserId;

  final Set<String> _consumedFailureTriggers = {};

  final Map<String, List<Message>> _messagesByConsultation = {
    // cons_seed_2: already-completed written consultation (see
    // ConsultationsMockDataSource) — a multi-day, fully-read transcript
    // covering all three MessageTypes so the post-end read-only state has
    // something realistic to render.
    'cons_seed_2': [
      Message(
        id: 'msg_new_cs2_1',
        consultationId: 'cons_seed_2',
        senderId: clientId,
        senderRole: UserRole.client,
        type: MessageType.text,
        text: 'مرحبًا دكتورة سارة، أرفقت لك صورة من صفحة العقد التي أحتاج رأيك فيها.',
        sentAt: DateTime.now().subtract(const Duration(days: 3, hours: 2, minutes: 10)),
        readAt: DateTime.now().subtract(const Duration(days: 3, hours: 1, minutes: 50)),
      ),
      Message(
        id: 'msg_new_cs2_2',
        consultationId: 'cons_seed_2',
        senderId: clientId,
        senderRole: UserRole.client,
        type: MessageType.image,
        attachmentUrl: 'mock://images/lease_page_4.jpg',
        sentAt: DateTime.now().subtract(const Duration(days: 3, hours: 2, minutes: 5)),
        readAt: DateTime.now().subtract(const Duration(days: 3, hours: 1, minutes: 50)),
      ),
      Message(
        id: 'msg_new_cs2_3',
        consultationId: 'cons_seed_2',
        senderId: lawyerId,
        senderRole: UserRole.lawyer,
        type: MessageType.text,
        text: 'أهلاً بك، اطلعت على الصورة. بند الفسخ المبكر في الصفحة الرابعة يحتاج صياغة أوضح — سأرسل لك نموذجًا بديلاً.',
        sentAt: DateTime.now().subtract(const Duration(days: 3, hours: 1, minutes: 40)),
        readAt: DateTime.now().subtract(const Duration(days: 3, hours: 1, minutes: 20)),
      ),
      Message(
        id: 'msg_new_cs2_4',
        consultationId: 'cons_seed_2',
        senderId: lawyerId,
        senderRole: UserRole.lawyer,
        type: MessageType.file,
        attachmentUrl: 'mock://files/بند_فسخ_مقترح.pdf',
        sentAt: DateTime.now().subtract(const Duration(days: 2, hours: 20)),
        readAt: DateTime.now().subtract(const Duration(days: 2, hours: 19, minutes: 30)),
      ),
      Message(
        id: 'msg_new_cs2_5',
        consultationId: 'cons_seed_2',
        senderId: clientId,
        senderRole: UserRole.client,
        type: MessageType.text,
        text: 'شكرًا جزيلاً، الصياغة الجديدة أوضح بكثير. سأرسلها للطرف الآخر اليوم.',
        sentAt: DateTime.now().subtract(const Duration(days: 2, hours: 19)),
        readAt: DateTime.now().subtract(const Duration(days: 2, hours: 18, minutes: 45)),
      ),
      Message(
        id: 'msg_new_cs2_6',
        consultationId: 'cons_seed_2',
        senderId: lawyerId,
        senderRole: UserRole.lawyer,
        type: MessageType.text,
        text: 'موفقة إن شاء الله، لا تترددي بالتواصل إذا احتجتِ أي تعديل إضافي.',
        sentAt: DateTime.now().subtract(const Duration(days: 2, hours: 18, minutes: 40)),
        readAt: DateTime.now().subtract(const Duration(days: 2, hours: 18, minutes: 30)),
      ),
    ],

    // cons_seed_6: confirmed written consultation scheduled to start within
    // minutes (see ConsultationsMockDataSource) — a short pre-session
    // logistics exchange with the lawyer's last message left UNREAD so the
    // consultations-list badge has something real to demonstrate before the
    // client ever opens the chat room.
    'cons_seed_6': [
      Message(
        id: 'msg_new_cs6_1',
        consultationId: 'cons_seed_6',
        senderId: clientId,
        senderRole: UserRole.client,
        type: MessageType.text,
        text: 'مرحبًا، هل يمكن أن أرسل تفاصيل إضافية عن المشكلة قبل بدء الجلسة؟',
        sentAt: DateTime.now().subtract(const Duration(hours: 5)),
        readAt: DateTime.now().subtract(const Duration(hours: 4, minutes: 50)),
      ),
      Message(
        id: 'msg_new_cs6_2',
        consultationId: 'cons_seed_6',
        senderId: lawyerId,
        senderRole: UserRole.lawyer,
        type: MessageType.text,
        text: 'تفضل، أرسل أي مستندات أو تفاصيل الآن وسأطلع عليها قبل موعدنا.',
        sentAt: DateTime.now().subtract(const Duration(hours: 4, minutes: 45)),
        readAt: null,
      ),
    ],
  };

  int _messageSequence = 0;

  @override
  Future<List<Message>> getMessages(String consultationId) async {
    await _simulateLatency();
    final messages = List<Message>.of(_messagesByConsultation[consultationId] ?? const []);
    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return messages;
  }

  @override
  Future<Message> sendMessage({
    required String consultationId,
    required String senderId,
    required UserRole senderRole,
    required MessageType type,
    String text = '',
    String? attachmentUrl,
  }) async {
    await _simulateLatency();
    if (type == MessageType.text && text.trim().isEmpty) {
      throw const ValidationFailure(message: 'Message text must not be empty.');
    }
    if (type == MessageType.text && text.trim() == kMockChatFailureTrigger) {
      final key = '$consultationId::${text.trim()}';
      if (_consumedFailureTriggers.add(key)) {
        throw const NetworkFailure(message: 'Simulated network failure.');
      }
    }
    final message = Message(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}_${_messageSequence++}',
      consultationId: consultationId,
      senderId: senderId,
      senderRole: senderRole,
      type: type,
      text: text,
      attachmentUrl: attachmentUrl,
      sentAt: DateTime.now(),
    );
    _messagesByConsultation.putIfAbsent(consultationId, () => []).add(message);
    return message;
  }

  @override
  Future<void> markAllRead({required String consultationId, required UserRole viewerRole}) async {
    await _simulateLatency();
    final messages = _messagesByConsultation[consultationId];
    if (messages == null) return;
    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (message.senderRole != viewerRole && message.readAt == null) {
        messages[i] = message.copyWith(readAt: DateTime.now());
      }
    }
  }

  @override
  Future<Map<String, int>> getUnreadCounts({required UserRole viewerRole}) async {
    await _simulateLatency();
    return {
      for (final entry in _messagesByConsultation.entries)
        entry.key: entry.value.where((m) => m.senderRole != viewerRole && m.readAt == null).length,
    }..removeWhere((_, count) => count == 0);
  }

  Future<void> _simulateLatency() => Future.delayed(const Duration(milliseconds: 300));
}
