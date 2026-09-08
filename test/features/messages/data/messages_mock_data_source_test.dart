import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/messages/data/datasources/messages_mock_data_source.dart';
import 'package:aqd_ionbit/features/messages/domain/entities/message_type.dart';

void main() {
  late MessagesMockDataSource dataSource;

  setUp(() => dataSource = MessagesMockDataSource());

  test('getMessages returns the seeded transcript sorted oldest first', () async {
    final messages = await dataSource.getMessages('cons_seed_2');
    expect(messages, isNotEmpty);
    for (var i = 1; i < messages.length; i++) {
      expect(messages[i].sentAt.isAfter(messages[i - 1].sentAt) || messages[i].sentAt.isAtSameMomentAs(messages[i - 1].sentAt), isTrue);
    }
  });

  test('getMessages returns an empty list for an unknown consultation', () async {
    final messages = await dataSource.getMessages('does_not_exist');
    expect(messages, isEmpty);
  });

  test('sendMessage appends and assigns id/sentAt', () async {
    final before = await dataSource.getMessages('cons_seed_6');
    final sent = await dataSource.sendMessage(
      consultationId: 'cons_seed_6',
      senderId: 'u_client_1',
      senderRole: UserRole.client,
      type: MessageType.text,
      text: 'test message',
    );
    expect(sent.id, isNotEmpty);
    expect(sent.text, 'test message');
    final after = await dataSource.getMessages('cons_seed_6');
    expect(after.length, before.length + 1);
  });

  test('sendMessage throws ValidationFailure for empty text', () async {
    expect(
      () => dataSource.sendMessage(consultationId: 'cons_seed_6', senderId: 'u_client_1', senderRole: UserRole.client, type: MessageType.text, text: '   '),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('markAllRead marks only the other party\'s unread messages', () async {
    final before = await dataSource.getMessages('cons_seed_6');
    final unreadFromLawyer = before.where((m) => m.senderRole == UserRole.lawyer && m.readAt == null);
    expect(unreadFromLawyer, isNotEmpty);

    await dataSource.markAllRead(consultationId: 'cons_seed_6', viewerRole: UserRole.client);

    final after = await dataSource.getMessages('cons_seed_6');
    expect(after.where((m) => m.senderRole == UserRole.lawyer && m.readAt == null), isEmpty);
  });

  test('getUnreadCounts reports cons_seed_6 as unread for the client, excludes read-through consultations', () async {
    final counts = await dataSource.getUnreadCounts(viewerRole: UserRole.client);
    expect(counts['cons_seed_6'], 1);
    expect(counts.containsKey('cons_seed_2'), isFalse);
  });

  test('getUnreadCounts drops to empty after markAllRead', () async {
    await dataSource.markAllRead(consultationId: 'cons_seed_6', viewerRole: UserRole.client);
    final counts = await dataSource.getUnreadCounts(viewerRole: UserRole.client);
    expect(counts.containsKey('cons_seed_6'), isFalse);
  });

  test('the lawyer never sees her own messages counted as unread', () async {
    final counts = await dataSource.getUnreadCounts(viewerRole: UserRole.lawyer);
    expect(counts.containsKey('cons_seed_6'), isFalse);
  });

  test('sending the reserved failure-trigger text throws once, then succeeds identically on retry', () async {
    final before = await dataSource.getMessages('cons_seed_6');

    await expectLater(
      () => dataSource.sendMessage(
        consultationId: 'cons_seed_6',
        senderId: 'u_client_1',
        senderRole: UserRole.client,
        type: MessageType.text,
        text: kMockChatFailureTrigger,
      ),
      throwsA(isA<NetworkFailure>()),
    );
    final afterFailure = await dataSource.getMessages('cons_seed_6');
    expect(afterFailure.length, before.length, reason: 'the failed send must not have appended anything');

    // Identical retry (same consultation, same text) now succeeds.
    final retried = await dataSource.sendMessage(
      consultationId: 'cons_seed_6',
      senderId: 'u_client_1',
      senderRole: UserRole.client,
      type: MessageType.text,
      text: kMockChatFailureTrigger,
    );
    expect(retried.text, kMockChatFailureTrigger);
    final afterRetry = await dataSource.getMessages('cons_seed_6');
    expect(afterRetry.length, before.length + 1);
  });

  test('the failure trigger is scoped per consultation — a fresh consultation still fails once', () async {
    // Consumes cons_seed_6's one guaranteed failure.
    await expectLater(
      () => dataSource.sendMessage(
        consultationId: 'cons_seed_6',
        senderId: 'u_client_1',
        senderRole: UserRole.client,
        type: MessageType.text,
        text: kMockChatFailureTrigger,
      ),
      throwsA(isA<NetworkFailure>()),
    );

    await expectLater(
      () => dataSource.sendMessage(
        consultationId: 'cons_seed_2',
        senderId: 'u_client_1',
        senderRole: UserRole.client,
        type: MessageType.text,
        text: kMockChatFailureTrigger,
      ),
      throwsA(isA<NetworkFailure>()),
    );
  });
}
