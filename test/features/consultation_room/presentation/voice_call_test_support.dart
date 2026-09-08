import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_theme.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/consultation_room/data/datasources/consultation_room_data_source_provider.dart';
import 'package:aqd_ionbit/features/consultation_room/data/datasources/consultation_room_mock_data_source.dart';
import 'package:aqd_ionbit/features/consultation_room/presentation/screens/voice_call_screen.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_data_source_provider.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_mock_data_source.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_remote_data_source.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

import '../../messages/presentation/chat_room_test_support.dart' show FixedAuthController;
import 'consultation_waiting_screen_test_support.dart' show consultationDetailsPatternFor, voiceCallPatternFor;

/// A voice consultation fixture pinned to one of `ConsultationsMockDataSource`'s
/// seeded IDs (`cons_seed_8`/`_9`/`_11` — reliable / recovers-on-retry /
/// never-connects respectively, see that file's doc comment) so
/// `ConsultationRoomMockDataSource`'s hash-seeded connection profile stays
/// deterministic even when the test needs a controlled `scheduledAt`/`status`
/// that the seed data itself doesn't provide (mirrors `readyConsultation` in
/// `chat_room_test_support.dart` for the same reason).
Consultation voiceConsultation({
  String id = 'cons_seed_8',
  ConsultationStatus status = ConsultationStatus.confirmed,
  DateTime? scheduledAt,
  String lawyerName = 'سارة المطيري',
  String clientName = 'أحمد العتيبي',
}) {
  return Consultation(
    id: id,
    lawyerId: 'lwr_seed_1',
    lawyerName: lawyerName,
    clientName: clientName,
    type: ConsultationType.voice,
    status: status,
    scheduledAt: scheduledAt ?? DateTime.now(),
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    price: 180,
  );
}

Future<ProviderContainer> pumpVoiceCall(
  WidgetTester tester, {
  required AuthUser user,
  required String consultationId,
  ConsultationsRemoteDataSource? consultationsDataSource,
  String routeBase = RoutePaths.clientBase,
  Locale locale = const Locale('en'),
  int settleTicks = 8,
}) async {
  final container = ProviderContainer(
    overrides: [
      authControllerProvider.overrideWith(() => FixedAuthController(user)),
      consultationsRemoteDataSourceProvider.overrideWithValue(consultationsDataSource ?? ConsultationsMockDataSource()),
      consultationRoomRemoteDataSourceProvider.overrideWithValue(ConsultationRoomMockDataSource()),
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: RoutePaths.voiceCallFor(routeBase, consultationId),
    routes: [
      GoRoute(
        path: voiceCallPatternFor(routeBase),
        builder: (context, state) => VoiceCallScreen(consultationId: state.pathParameters['id']!, routeBase: routeBase),
      ),
      GoRoute(path: consultationDetailsPatternFor(routeBase), builder: (context, state) => const Scaffold(body: Text('details screen'))),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.light,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
      ),
    ),
  );
  // Let the consultations/session mock-latency fetches resolve, and the
  // waiting -> ready -> connect auto-chain run to completion (each hop has
  // its own simulated latency, so this needs several rounds).
  for (var i = 0; i < settleTicks; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
  return container;
}
