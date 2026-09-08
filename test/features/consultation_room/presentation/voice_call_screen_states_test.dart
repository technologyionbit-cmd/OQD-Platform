import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';

import '../../messages/presentation/chat_room_test_support.dart' show SingleConsultationDataSource, testClient, testLawyer;
import 'voice_call_test_support.dart';

void main() {
  testWidgets('the voice call screen loads without throwing', (tester) async {
    await pumpVoiceCall(tester, user: testClient, consultationId: 'cons_seed_8');

    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the connecting state before the session reaches active', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
      settleTicks: 2,
    );

    expect(find.text('Connecting…'), findsOneWidget);
    expect(find.text('Voice Consultation'), findsOneWidget);
    expect(find.text(consultation.lawyerName), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // Drain the still-pending mock-latency timers so none are left running
    // when the test ends (mirrors ConsultationWaitingScreen's own
    // "loading state" test for the same reason).
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
  });

  testWidgets('a reliable seed reaches active with the call controls visible', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Mute'), findsOneWidget);
    expect(find.text('Turn speaker off'), findsOneWidget);
    expect(find.text('End Call'), findsOneWidget);
  });

  testWidgets('active call shows the other participant', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.text(consultation.lawyerName), findsOneWidget);
  });

  testWidgets('active call shows a running duration that keeps incrementing', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
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
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.tap(find.byTooltip('Mute'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Unmute'), findsOneWidget);
    expect(find.text('Mute'), findsNothing);
  });

  testWidgets('tapping the speaker toggle flips its label', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.text('Turn speaker off'), findsOneWidget);

    await tester.tap(find.byTooltip('Turn speaker off'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Turn speaker on'), findsOneWidget);
  });

  testWidgets('no camera control appears anywhere on the call screen', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.textContaining('Camera'), findsNothing);
    expect(find.textContaining('camera'), findsNothing);
  });

  testWidgets('a recovers-on-retry seed shows the connection-lost/reconnecting state', (tester) async {
    final consultation = voiceConsultation(id: 'cons_seed_11');
    await pumpVoiceCall(
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
    final consultation = voiceConsultation(id: 'cons_seed_11');
    await pumpVoiceCall(
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
    final consultation = voiceConsultation(id: 'cons_seed_9');
    await pumpVoiceCall(
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
    await pumpVoiceCall(tester, user: testClient, consultationId: 'cons_seed_8');

    expect(find.text('سارة المطيري'), findsOneWidget);
  });

  testWidgets('lawyer view shows the client as the other participant', (tester) async {
    await pumpVoiceCall(tester, user: testLawyer, consultationId: 'cons_seed_8', routeBase: RoutePaths.lawyerBase);

    expect(find.text('أحمد العتيبي'), findsOneWidget);
  });

  testWidgets('renders in Arabic when the app locale is Arabic', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
      locale: const Locale('ar'),
    );

    expect(find.text('استشارة صوتية'), findsOneWidget);
    expect(find.text('متصل'), findsOneWidget);
  });

  testWidgets('system back is blocked while the call is active, so it cannot silently exit an active call', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );
    expect(find.text('Connected'), findsOneWidget);

    // The AppBar's own back button already routes an active call through
    // the end-confirmation dialog — PopScope.canPop must be false here too,
    // or the OS back gesture/button bypasses that dialog entirely and exits
    // a still-`active` mock session with no confirmation.
    // `PopScope` is generic (`PopScope<T>`) in this Flutter version, so
    // `find.byType(PopScope)` (implicitly `PopScope<dynamic>`) misses the
    // concrete `PopScope<Object>` instance in the tree — a raw `is` check
    // matches any type argument instead.
    final popScope = tester.widgetList(find.byWidgetPredicate((w) => w is PopScope)).single as PopScope;
    expect(popScope.canPop, isFalse);
  });

  testWidgets('system back is allowed once the call has ended', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );
    expect(find.text('Connected'), findsOneWidget);

    await tester.tap(find.text('End Call'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(TextButton, 'End Call'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Consultation ended'), findsOneWidget);
    final popScope = tester.widgetList(find.byWidgetPredicate((w) => w is PopScope)).single as PopScope;
    expect(popScope.canPop, isTrue);
  });

  testWidgets('a cancelled consultation never auto-joins — shows unavailable instead of connecting', (tester) async {
    final consultation = voiceConsultation(status: ConsultationStatus.cancelled);
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
      settleTicks: 2,
    );

    // Reaching this route directly for a cancelled booking (stale deep
    // link, browser back/forward, a re-pushed route) must never drive the
    // session controller at all — no "Connecting…"/spinner, straight to the
    // unavailable state.
    expect(find.text('Connecting…'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Unable to connect'), findsOneWidget);
  });

  testWidgets('a pending-approval consultation never auto-joins', (tester) async {
    final consultation = voiceConsultation(status: ConsultationStatus.pendingApproval);
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
      settleTicks: 2,
    );

    expect(find.text('Connecting…'), findsNothing);
    expect(find.text('Unable to connect'), findsOneWidget);
  });

  testWidgets('renders in English by default', (tester) async {
    final consultation = voiceConsultation();
    await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.text('Voice Consultation'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
  });
}
