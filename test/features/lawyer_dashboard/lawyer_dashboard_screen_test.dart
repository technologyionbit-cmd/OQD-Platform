import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_theme.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_data_source_provider.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_mock_data_source.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/lawyer_dashboard/presentation/screens/lawyer_dashboard_screen.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_data_source_provider.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_mock_data_source.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/verification_status.dart';
import 'package:aqd_ionbit/features/notifications/data/datasources/notifications_data_source_provider.dart';
import 'package:aqd_ionbit/features/notifications/data/datasources/notifications_mock_data_source.dart';

import '../../support/role_test_harness.dart' show testLawyer;
import '../../support/signed_in_override.dart';
import '../messages/presentation/chat_room_test_support.dart' show FixedAuthController;

/// Returns exactly [consultations], like the server does for the signed-in
/// lawyer.
class _FixedConsultations extends ConsultationsMockDataSource {
  _FixedConsultations(this.consultations);
  final List<Consultation> consultations;

  @override
  Future<List<Consultation>> getConsultations() async => consultations;
}

class _LawyerWithStatus extends LawyersMockDataSource {
  _LawyerWithStatus(this.status);
  final VerificationStatus status;

  @override
  Future<LawyerProfile> getMyProfile() async => (await super.getMyProfile()).copyWith(verificationStatus: status);
}

Consultation _confirmed(DateTime scheduledAt) => Consultation(
  id: 'c_live',
  // A real server id: the dashboard must not filter by any fixed lawyer id.
  lawyerId: '7f1e7a52-2d4f-4c61-9d0c-5b8e8a1d0c11',
  lawyerName: 'Lawyer User',
  clientName: 'Omar Client',
  type: ConsultationType.video,
  status: ConsultationStatus.confirmed,
  scheduledAt: scheduledAt,
  createdAt: DateTime.now().subtract(const Duration(days: 1)),
  price: 50,
);

Future<void> _pump(
  WidgetTester tester, {
  List<Consultation> consultations = const [],
  VerificationStatus status = VerificationStatus.verified,
}) async {
  tester.view.physicalSize = const Size(420, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      signedInOverride,
      authControllerProvider.overrideWith(() => FixedAuthController(testLawyer)),
      consultationsRemoteDataSourceProvider.overrideWithValue(_FixedConsultations(consultations)),
      lawyersRemoteDataSourceProvider.overrideWithValue(_LawyerWithStatus(status)),
      notificationsRemoteDataSourceProvider.overrideWithValue(NotificationsMockDataSource()),
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: RoutePaths.lawyerDashboard,
    routes: [
      GoRoute(path: RoutePaths.lawyerDashboard, builder: (context, state) => const LawyerDashboardScreen()),
      GoRoute(path: RoutePaths.lawyerProfileEdit, builder: (context, state) => const Scaffold(body: Text('profile-edit'))),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
      ),
    ),
  );
  // The mocks answer after a short Future.delayed latency, which
  // pumpAndSettle alone does not always wait out; the cards that appear
  // once consultations load start fetches of their own.
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('shows the consultations the server returns, whatever the lawyer id', (tester) async {
    await _pump(tester, consultations: [_confirmed(DateTime.now().add(const Duration(hours: 3)))]);

    expect(find.text('Omar Client'), findsWidgets);
  });

  testWidgets('keeps the session banner while the session is still running', (tester) async {
    await _pump(tester, consultations: [_confirmed(DateTime.now().subtract(const Duration(minutes: 25)))]);

    expect(find.text('Start Session'), findsOneWidget);
  });

  testWidgets('drops the session banner once the session time is over', (tester) async {
    await _pump(tester, consultations: [_confirmed(DateTime.now().subtract(const Duration(minutes: 90)))]);

    expect(find.text('Start Session'), findsNothing);
  });

  testWidgets('tells an unverified lawyer why clients cannot book them', (tester) async {
    await _pump(tester, status: VerificationStatus.unverified);

    expect(find.text('Your account is not verified yet'), findsOneWidget);
    await tester.tap(find.text('Complete verification'));
    await tester.pumpAndSettle();
    expect(find.text('profile-edit'), findsOneWidget);
  });

  testWidgets('shows a pending review without an action', (tester) async {
    await _pump(tester, status: VerificationStatus.pending);

    expect(find.text('Verification under review'), findsOneWidget);
    expect(find.text('Complete verification'), findsNothing);
  });

  testWidgets('shows no verification banner once verified', (tester) async {
    await _pump(tester);

    expect(find.text('Your account is not verified yet'), findsNothing);
    expect(find.text('Verification under review'), findsNothing);
  });

  testWidgets('shows the unread notifications count on the bell', (tester) async {
    await _pump(tester);

    // The notifications mock seeds two unread notifications.
    expect(find.descendant(of: find.byType(Badge), matching: find.text('2')), findsOneWidget);
  });
}
