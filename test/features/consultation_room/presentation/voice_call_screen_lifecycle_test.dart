import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../messages/presentation/chat_room_test_support.dart' show SingleConsultationDataSource, testClient;
import 'voice_call_test_support.dart';

void main() {
  testWidgets('End Call shows a confirmation dialog', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.tap(find.text('End Call'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('End consultation?'), findsOneWidget);
    expect(find.text('Keep Call'), findsOneWidget);
  });

  testWidgets('confirming End Call ends the session', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.tap(find.text('End Call'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(TextButton, 'End Call'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Consultation ended'), findsOneWidget);
    expect(find.text('Mute'), findsNothing);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('cancelling (Keep Call) leaves the call active', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.tap(find.text('End Call'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Keep Call'));
    await tester.pumpAndSettle();

    expect(find.text('End consultation?'), findsNothing);
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Mute'), findsOneWidget);
  });

  testWidgets('the session auto-ends once the max duration elapses, with no confirmation dialog', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.text('Mute'), findsOneWidget);

    await tester.pump(const Duration(hours: 1));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Mute'), findsNothing);
    expect(find.text('Consultation ended'), findsOneWidget);
    expect(find.text('The maximum consultation duration has been reached.'), findsOneWidget);
    expect(find.text('End consultation?'), findsNothing);
  });

  testWidgets('shows a first warning banner with 5 minutes remaining', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.pump(const Duration(minutes: 56));

    expect(find.text('The session will end soon'), findsOneWidget);
  });

  testWidgets('shows a final warning banner with 1 minute remaining', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.pump(const Duration(minutes: 59, seconds: 30));

    expect(find.text('Less than a minute left'), findsOneWidget);
  });

  testWidgets('the back arrow returns to the consultation details route', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
      settleTicks: 1,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('details screen'), findsOneWidget);
  });

  for (final size in const [Size(320, 568), Size(430, 932), Size(1024, 800)]) {
    testWidgets('renders with no overflow at ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final consultation = voiceConsultation();
      await pumpVoiceCall(
        tester,
        user: testClient,
        consultationId: consultation.id,
        consultationsDataSource: SingleConsultationDataSource(consultation),
      );

      expect(tester.takeException(), isNull);
    });
  }
}
