import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/messages/data/datasources/messages_mock_data_source.dart';

import 'chat_room_test_support.dart';

void main() {
  testWidgets("opening the chat room marks the other party's unread messages as read", (tester) async {
    final messagesDataSource = MessagesMockDataSource();
    // `MessagesMockDataSource` has its own simulated `Future.delayed`
    // latency — calling it directly (not through `tester.pump`) inside a
    // widget test must go through `runAsync`, which runs the callback in
    // the real (non-fake-async) zone; awaiting it directly here would hang
    // forever, since nothing would ever elapse the fake clock for it.
    final before = await tester.runAsync(() => messagesDataSource.getUnreadCounts(viewerRole: UserRole.client));
    expect(before!['cons_seed_6'], 1);

    await pumpChatRoom(tester, user: testClient, consultationId: 'cons_seed_6', messagesDataSource: messagesDataSource);
    await tester.pump(const Duration(milliseconds: 400));

    final after = await tester.runAsync(() => messagesDataSource.getUnreadCounts(viewerRole: UserRole.client));
    expect(after!.containsKey('cons_seed_6'), isFalse);
  });

  testWidgets('ending the consultation via the overflow menu freezes the composer', (tester) async {
    final consultation = readyConsultation(id: 'cons_end');
    await pumpChatRoom(tester, user: testLawyer, consultationId: 'cons_end', consultationsDataSource: SingleConsultationDataSource(consultation));

    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('End Consultation'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // The confirmation dialog's own confirm action is the localized
    // "Confirm" label (see `showConfirmationDialog`), not a second
    // "End Consultation" — only one such text exists on screen at this point.
    await tester.tap(find.text('Confirm'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(TextField), findsNothing);
    expect(find.text('This consultation has ended'), findsWidgets);
  });

  testWidgets('the session auto-ends once the max duration elapses', (tester) async {
    final consultation = readyConsultation(id: 'cons_timer');
    await pumpChatRoom(tester, user: testClient, consultationId: 'cons_timer', consultationsDataSource: SingleConsultationDataSource(consultation));

    expect(find.byType(TextField), findsOneWidget);

    await tester.pump(const Duration(hours: 1));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(TextField), findsNothing);
    expect(find.text('This consultation has ended'), findsWidgets);
  });

  testWidgets('the overflow menu navigates to the consultation details route', (tester) async {
    final consultation = readyConsultation(id: 'cons_nav');
    await pumpChatRoom(tester, user: testClient, consultationId: 'cons_nav', consultationsDataSource: SingleConsultationDataSource(consultation));

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('View consultation details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('details screen'), findsOneWidget);
  });
}
