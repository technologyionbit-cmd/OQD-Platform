import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/messages/data/datasources/messages_mock_data_source.dart';

import 'chat_room_test_support.dart';

void main() {
  testWidgets('loads and displays the seeded written-chat transcript (cons_seed_6)', (tester) async {
    await pumpChatRoom(tester, user: testClient, consultationId: 'cons_seed_6', locale: const Locale('ar'));

    expect(find.textContaining('تفاصيل إضافية'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget); // composer present -> session reached `active`
  });

  testWidgets('shows the pre-consultation lobby state for a far-future written consultation (cons_seed_7)', (tester) async {
    await pumpChatRoom(tester, user: testClient, consultationId: 'cons_seed_7');

    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('Written Consultation'), findsWidgets);
  });

  testWidgets('shows an invalid-consultation state for an unknown ID', (tester) async {
    await pumpChatRoom(tester, user: testClient, consultationId: 'does_not_exist');

    expect(find.text('This consultation could not be found.'), findsOneWidget);
  });

  testWidgets('shows an empty state for a fresh consultation with no messages yet', (tester) async {
    final consultation = readyConsultation(id: 'cons_empty');
    await pumpChatRoom(
      tester,
      user: testClient,
      consultationId: 'cons_empty',
      consultationsDataSource: SingleConsultationDataSource(consultation),
      messagesDataSource: MessagesMockDataSource(),
    );

    expect(find.text('No messages yet'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('a completed consultation shows the read-only transcript, not the pre-session lobby', (tester) async {
    final consultation = readyConsultation(id: 'cons_completed', status: ConsultationStatus.completed);
    await pumpChatRoom(
      tester,
      user: testClient,
      consultationId: 'cons_completed',
      consultationsDataSource: SingleConsultationDataSource(consultation),
      messagesDataSource: MessagesMockDataSource(),
    );

    // Straight to the ended transcript view — no composer, no "opens at a
    // moment already in the past" lobby countdown.
    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('ended'), findsWidgets);
  });

  testWidgets('a cancelled consultation shows unavailable instead of the pre-session lobby', (tester) async {
    final consultation = readyConsultation(id: 'cons_cancelled_chat', status: ConsultationStatus.cancelled);
    await pumpChatRoom(
      tester,
      user: testClient,
      consultationId: 'cons_cancelled_chat',
      consultationsDataSource: SingleConsultationDataSource(consultation),
      messagesDataSource: MessagesMockDataSource(),
    );

    expect(find.byType(TextField), findsNothing);
    expect(find.text('View consultation details'), findsOneWidget);
  });

  testWidgets('renders in Arabic when the app locale is Arabic', (tester) async {
    final consultation = readyConsultation(id: 'cons_ar', status: ConsultationStatus.confirmed);
    await pumpChatRoom(
      tester,
      user: testClient,
      consultationId: 'cons_ar',
      consultationsDataSource: SingleConsultationDataSource(consultation),
      locale: const Locale('ar'),
    );

    expect(find.text('لا توجد رسائل بعد'), findsOneWidget);
  });
}
