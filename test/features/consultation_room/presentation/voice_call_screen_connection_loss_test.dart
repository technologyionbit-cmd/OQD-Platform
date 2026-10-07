import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../messages/presentation/chat_room_test_support.dart' show SingleConsultationDataSource, testClient;
import 'voice_call_test_support.dart';

/// Covers the dev-only "Simulate connection loss" trigger added to give the
/// mock `reportConnectionLost()` path (previously unreachable from any UI —
/// see `SessionController`) a deterministic way to be exercised, both by a
/// developer during manual QA and by these automated tests.
void main() {
  testWidgets('active -> simulated connection loss -> reconnecting -> retry succeeds -> active again', (tester) async {
    // cons_seed_8 hashes to the reliable connection profile — reaches
    // active immediately, and (per ConsultationRoomMockDataSource) also
    // reconnects reliably on retry after a simulated mid-call drop.
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );
    expect(find.text('Connected'), findsOneWidget);

    final devTrigger = find.byTooltip('Simulate connection loss (dev)');
    expect(devTrigger, findsOneWidget);
    await tester.tap(devTrigger);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Connection lost'), findsOneWidget);
    expect(find.text('Reconnecting… Attempt 1 of 3'), findsOneWidget);

    await tester.ensureVisible(find.text('Retry Now'));
    await tester.tap(find.text('Retry Now'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Connection lost'), findsNothing);
  });

  testWidgets('the dev trigger is not shown once the call has ended', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );
    expect(find.byTooltip('Simulate connection loss (dev)'), findsOneWidget);

    await tester.tap(find.text('End Call'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(TextButton, 'End Call'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Consultation ended'), findsOneWidget);
    expect(find.byTooltip('Simulate connection loss (dev)'), findsNothing);
  });
}
