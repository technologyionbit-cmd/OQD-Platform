import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../messages/presentation/chat_room_test_support.dart' show SingleConsultationDataSource, testClient;
import 'video_call_test_support.dart';

/// Mirrors `voice_call_screen_connection_loss_test.dart` — same dev-only
/// "Simulate connection loss" trigger, same `SessionController`/mock
/// data-source plumbing, just the video screen's own widget tree.
void main() {
  testWidgets('active -> simulated connection loss -> reconnecting -> retry succeeds -> active again', (tester) async {
    final consultation = videoConsultation(id: 'cons_seed_8');
    await pumpVideoCall(
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
    final consultation = videoConsultation();
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );
    expect(find.byTooltip('Simulate connection loss (dev)'), findsOneWidget);

    // Video's in-call End Call control is icon+tooltip only (no visible
    // caption, unlike voice's) — see _VideoControlButton.
    await tester.tap(find.byTooltip('End Call'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(TextButton, 'End Call'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Consultation ended'), findsOneWidget);
    expect(find.byTooltip('Simulate connection loss (dev)'), findsNothing);
  });
}
