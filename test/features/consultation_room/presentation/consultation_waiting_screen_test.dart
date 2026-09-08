import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

import '../../messages/presentation/chat_room_test_support.dart' show SingleConsultationDataSource, testClient, testLawyer;
import 'consultation_waiting_screen_test_support.dart';

Consultation _consultation({
  String id = 'cons_wait_test',
  ConsultationType type = ConsultationType.written,
  ConsultationStatus status = ConsultationStatus.confirmed,
  required DateTime scheduledAt,
}) {
  return Consultation(
    id: id,
    lawyerId: 'lwr_seed_1',
    lawyerName: 'سارة المطيري',
    clientName: 'أحمد العتيبي',
    type: type,
    status: status,
    scheduledAt: scheduledAt,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    price: 100,
  );
}

void main() {
  testWidgets('shows an invalid-consultation state for an unknown ID', (tester) async {
    await pumpWaitingScreen(tester, user: testClient, consultationId: 'does_not_exist');

    expect(find.text('This consultation could not be found.'), findsOneWidget);
  });

  testWidgets('shows a loading state before the fetch resolves', (tester) async {
    await pumpWaitingScreen(tester, user: testClient, consultationId: 'cons_seed_6', settle: false);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // Drain the still-pending mock-latency timers so none are left running
    // when the test ends.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
  });

  testWidgets('too-early state hides the join action and shows a countdown', (tester) async {
    final consultation = _consultation(scheduledAt: DateTime.now().add(const Duration(days: 2)));
    await pumpWaitingScreen(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.text('Not time yet'), findsOneWidget);
    expect(find.text('Your consultation will open 15 minutes before the scheduled time.'), findsOneWidget);
    expect(find.text('Join Consultation'), findsNothing);
  });

  testWidgets('join-window state shows Ready to join with an enabled Join button', (tester) async {
    final consultation = _consultation(scheduledAt: DateTime.now());
    await pumpWaitingScreen(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.text('Ready to join'), findsOneWidget);
    expect(find.text('Join Consultation'), findsOneWidget);
  });

  testWidgets('pressing Join on a written consultation drives the session to active and opens ChatRoomScreen', (tester) async {
    final consultation = _consultation(scheduledAt: DateTime.now());
    await pumpWaitingScreen(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.tap(find.text('Join Consultation'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }

    // Landed on ChatRoomScreen with the session already active: composer visible.
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Consultation Lobby'), findsNothing);
  });

  testWidgets('pressing Join on a voice consultation leaves the lobby and opens the voice call screen', (tester) async {
    final consultation = _consultation(type: ConsultationType.voice, scheduledAt: DateTime.now());
    await pumpWaitingScreen(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.tap(find.text('Join Consultation'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }

    expect(find.text('Consultation Lobby'), findsNothing);
    expect(find.text('Voice Call'), findsOneWidget);
  });

  testWidgets('pressing Join on a video consultation leaves the lobby and opens the video call screen', (tester) async {
    final consultation = _consultation(type: ConsultationType.video, scheduledAt: DateTime.now());
    await pumpWaitingScreen(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.tap(find.text('Join Consultation'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }

    expect(find.text('Consultation Lobby'), findsNothing);
    expect(find.text('Video Call'), findsOneWidget);
  });

  testWidgets('missed state cannot be joined', (tester) async {
    final consultation = _consultation(scheduledAt: DateTime.now().subtract(const Duration(minutes: 30)));
    await pumpWaitingScreen(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.text('Consultation missed'), findsOneWidget);
    expect(find.text('Join Consultation'), findsNothing);
  });

  testWidgets('cancelled consultation cannot be joined', (tester) async {
    final consultation = _consultation(status: ConsultationStatus.cancelled, scheduledAt: DateTime.now());
    await pumpWaitingScreen(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('Join Consultation'), findsNothing);
  });

  testWidgets('completed consultation cannot be joined', (tester) async {
    final consultation = _consultation(status: ConsultationStatus.completed, scheduledAt: DateTime.now());
    await pumpWaitingScreen(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Join Consultation'), findsNothing);
  });

  testWidgets('Back returns to consultation details', (tester) async {
    final consultation = _consultation(scheduledAt: DateTime.now().add(const Duration(days: 2)));
    await pumpWaitingScreen(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('details screen'), findsOneWidget);
  });

  testWidgets('renders in Arabic when the app locale is Arabic', (tester) async {
    final consultation = _consultation(scheduledAt: DateTime.now());
    await pumpWaitingScreen(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
      locale: const Locale('ar'),
    );

    expect(find.text('جاهز للانضمام'), findsOneWidget);
  });

  testWidgets('renders in English by default', (tester) async {
    final consultation = _consultation(scheduledAt: DateTime.now());
    await pumpWaitingScreen(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.text('Ready to join'), findsOneWidget);
  });

  testWidgets('client view shows the lawyer as the other party', (tester) async {
    final consultation = _consultation(scheduledAt: DateTime.now());
    await pumpWaitingScreen(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );

    expect(find.text(consultation.lawyerName), findsOneWidget);
  });

  testWidgets('lawyer view shows the client as the other party', (tester) async {
    final consultation = _consultation(scheduledAt: DateTime.now());
    await pumpWaitingScreen(
      tester,
      user: testLawyer,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
      routeBase: RoutePaths.lawyerBase,
    );

    expect(find.text(consultation.clientName), findsOneWidget);
  });

  for (final size in const [Size(320, 568), Size(430, 932), Size(1024, 800)]) {
    testWidgets('renders with no overflow at ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final consultation = _consultation(scheduledAt: DateTime.now());
      await pumpWaitingScreen(
        tester,
        user: testClient,
        consultationId: consultation.id,
        consultationsDataSource: SingleConsultationDataSource(consultation),
      );

      expect(tester.takeException(), isNull);
    });
  }
}
