import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/routing/route_paths.dart';

import '../../messages/presentation/chat_room_test_support.dart' show SingleConsultationDataSource, testClient, testLawyer;
import 'video_call_test_support.dart';

void main() {
  testWidgets('the video call screen loads without throwing', (tester) async {
    await pumpVideoCall(tester, user: testClient, consultationId: 'cons_seed_1');

    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the connecting state before the session reaches active', (tester) async {
    final consultation = videoConsultation();
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
      settleTicks: 2,
    );

    expect(find.text('Connecting…'), findsOneWidget);
    expect(find.text('Video Consultation'), findsOneWidget);
    expect(find.text(consultation.lawyerName), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // Drain the still-pending mock-latency timers so none are left running
    // when the test ends (mirrors VoiceCallScreen's own "connecting state"
    // test for the same reason).
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
  });

  testWidgets('a reliable seed reaches active with the call controls visible', (tester) async {
    final consultation = videoConsultation();
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.text('Connected'), findsOneWidget);
    expect(find.byTooltip('Mute'), findsOneWidget);
    expect(find.byTooltip('Camera off'), findsOneWidget);
    expect(find.byTooltip('Turn speaker off'), findsOneWidget);
    expect(find.byTooltip('Switch camera'), findsOneWidget);
    expect(find.byTooltip('End Call'), findsOneWidget);
  });

  testWidgets('active call shows the other participant', (tester) async {
    final consultation = videoConsultation();
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.text(consultation.lawyerName), findsOneWidget);
  });

  testWidgets('active call shows the remote video placeholder and local preview', (tester) async {
    final consultation = videoConsultation();
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.byKey(const Key('videoCallRemoteArea')), findsOneWidget);
    expect(find.byKey(const Key('videoCallLocalPreview')), findsOneWidget);
  });

  testWidgets('active call shows a running duration that keeps incrementing', (tester) async {
    final consultation = videoConsultation();
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    final durationPattern = RegExp(r'^\d{2}:\d{2}$');
    String currentDurationText() =>
        tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).whereType<String>().firstWhere(durationPattern.hasMatch);

    final before = int.parse(currentDurationText().split(':').last);

    await tester.pump(const Duration(seconds: 5));

    final after = int.parse(currentDurationText().split(':').last);
    expect(after, before + 5);
  });

  testWidgets('tapping Mute toggles to Unmute', (tester) async {
    final consultation = videoConsultation();
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.tap(find.byTooltip('Mute'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byTooltip('Unmute'), findsOneWidget);
    expect(find.byTooltip('Mute'), findsNothing);
  });

  testWidgets('tapping the speaker toggle flips its tooltip', (tester) async {
    final consultation = videoConsultation();
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.byTooltip('Turn speaker off'), findsOneWidget);

    await tester.tap(find.byTooltip('Turn speaker off'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byTooltip('Turn speaker on'), findsOneWidget);
  });

  testWidgets('tapping the camera toggle turns it off and shows the camera-off placeholder', (tester) async {
    final consultation = videoConsultation();
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.byTooltip('Camera off'), findsOneWidget);
    await tester.tap(find.byTooltip('Camera off'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byTooltip('Camera on'), findsOneWidget);
    expect(find.text('Camera is off'), findsOneWidget);
  });

  testWidgets('switch camera is disabled once the camera is off', (tester) async {
    final consultation = videoConsultation();
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.tap(find.byTooltip('Camera off'));
    await tester.pump(const Duration(milliseconds: 400));

    final switchButton = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.cameraswitch_outlined));
    expect(switchButton.onPressed, isNull);
  });

  testWidgets('tapping switch camera shows mock feedback without touching any camera API', (tester) async {
    final consultation = videoConsultation();
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.tap(find.byTooltip('Switch camera'));
    await tester.pump();

    expect(find.text('Switched to back camera'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an in-call chat affordance opens the chat room for the same consultation', (tester) async {
    final consultation = videoConsultation();
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.byTooltip('Chat'), findsOneWidget);
  });

  testWidgets('a recovers-on-retry seed shows the connection-lost/reconnecting state', (tester) async {
    final consultation = videoConsultation(id: 'cons_seed_11');
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.text('Connection lost'), findsOneWidget);
    expect(find.text('Reconnecting… Attempt 1 of 3'), findsOneWidget);
    expect(find.text('Retry Now'), findsOneWidget);
  });

  testWidgets('retrying a recovers-on-retry seed reaches active again', (tester) async {
    final consultation = videoConsultation(id: 'cons_seed_11');
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );
    expect(find.text('Reconnecting… Attempt 1 of 3'), findsOneWidget);

    await tester.ensureVisible(find.text('Retry Now'));
    await tester.tap(find.text('Retry Now'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Connection lost'), findsNothing);
  });

  testWidgets('a never-connects seed reaches a permanent failure / lawyer-unavailable state', (tester) async {
    final consultation = videoConsultation(id: 'cons_seed_9');
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );
    expect(find.text('Reconnecting… Attempt 1 of 3'), findsOneWidget);

    await tester.ensureVisible(find.text('Retry Now'));
    await tester.tap(find.text('Retry Now'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Reconnecting… Attempt 2 of 3'), findsOneWidget);

    await tester.ensureVisible(find.text('Retry Now'));
    await tester.tap(find.text('Retry Now'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Reconnecting… Attempt 3 of 3'), findsOneWidget);

    await tester.ensureVisible(find.text('Retry Now'));
    await tester.tap(find.text('Retry Now'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Unable to connect'), findsOneWidget);
    expect(find.text('Retry Now'), findsNothing);
    // The unavailable message names the other participant — a client's
    // lawyer, here — rather than a hardcoded "lawyer"/"client" literal.
    expect(find.textContaining(consultation.lawyerName), findsOneWidget);
  });

  testWidgets('client view shows the lawyer as the other participant', (tester) async {
    await pumpVideoCall(tester, user: testClient, consultationId: 'cons_seed_1');

    expect(find.text('سارة المطيري'), findsOneWidget);
  });

  testWidgets('lawyer view shows the client as the other participant', (tester) async {
    await pumpVideoCall(tester, user: testLawyer, consultationId: 'cons_seed_1', routeBase: RoutePaths.lawyerBase);

    expect(find.text('أحمد العتيبي'), findsOneWidget);
  });

  testWidgets('company view shows the lawyer as the other participant', (tester) async {
    final consultation = videoConsultation();
    await pumpVideoCall(
      tester,
      user: testCompany,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
      routeBase: RoutePaths.companyBase,
    );

    expect(find.text(consultation.lawyerName), findsOneWidget);
  });

  testWidgets('renders in Arabic when the app locale is Arabic', (tester) async {
    final consultation = videoConsultation();
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
      locale: const Locale('ar'),
    );

    expect(find.text('استشارة فيديو'), findsOneWidget);
    expect(find.text('متصل'), findsOneWidget);
  });

  testWidgets('renders in English by default', (tester) async {
    final consultation = videoConsultation();
    await pumpVideoCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.text('Video Consultation'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
  });
}
