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
import 'package:aqd_ionbit/features/consultation_room/presentation/screens/consultation_waiting_screen.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_data_source_provider.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_mock_data_source.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_remote_data_source.dart';
import 'package:aqd_ionbit/features/consultation_room/presentation/screens/voice_call_screen.dart';
import 'package:aqd_ionbit/features/consultation_room/presentation/screens/video_call_screen.dart';
import 'package:aqd_ionbit/features/messages/presentation/screens/chat_room_screen.dart';

import '../../messages/presentation/chat_room_test_support.dart' show FixedAuthController;

/// Shared harness for `ConsultationWaitingScreen` widget tests — mirrors
/// `pumpChatRoom` in `chat_room_test_support.dart` (same fixed-auth /
/// single-consultation / mock-session overrides), but drives the lobby
/// route instead and wires up the chat-room + consultation-details routes
/// it can navigate to, so a real `GoRouter` push/pop/redirect is exercised
/// rather than just the widget in isolation.
String consultationRoomPatternFor(String base) => switch (base) {
  RoutePaths.lawyerBase => RoutePaths.lawyerConsultationRoomPattern,
  RoutePaths.companyBase => RoutePaths.companyConsultationRoomPattern,
  _ => RoutePaths.clientConsultationRoomPattern,
};

String chatRoomPatternFor(String base) => switch (base) {
  RoutePaths.lawyerBase => RoutePaths.lawyerChatRoomPattern,
  RoutePaths.companyBase => RoutePaths.companyChatRoomPattern,
  _ => RoutePaths.clientChatRoomPattern,
};

String voiceCallPatternFor(String base) => switch (base) {
  RoutePaths.lawyerBase => RoutePaths.lawyerVoiceCallPattern,
  RoutePaths.companyBase => RoutePaths.companyVoiceCallPattern,
  _ => RoutePaths.clientVoiceCallPattern,
};

String videoCallPatternFor(String base) => switch (base) {
  RoutePaths.lawyerBase => RoutePaths.lawyerVideoCallPattern,
  RoutePaths.companyBase => RoutePaths.companyVideoCallPattern,
  _ => RoutePaths.clientVideoCallPattern,
};

String consultationDetailsPatternFor(String base) => switch (base) {
  RoutePaths.lawyerBase => RoutePaths.lawyerConsultationDetailsPattern,
  RoutePaths.companyBase => RoutePaths.companyConsultationDetailsPattern,
  _ => RoutePaths.clientConsultationDetailsPattern,
};

Future<ProviderContainer> pumpWaitingScreen(
  WidgetTester tester, {
  required AuthUser user,
  required String consultationId,
  ConsultationsRemoteDataSource? consultationsDataSource,
  String routeBase = RoutePaths.clientBase,
  Locale locale = const Locale('en'),
  bool settle = true,
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
    initialLocation: RoutePaths.consultationRoomFor(routeBase, consultationId),
    routes: [
      GoRoute(
        path: consultationRoomPatternFor(routeBase),
        builder: (context, state) => ConsultationWaitingScreen(consultationId: state.pathParameters['id']!, routeBase: routeBase),
      ),
      GoRoute(
        path: chatRoomPatternFor(routeBase),
        builder: (context, state) => ChatRoomScreen(consultationId: state.pathParameters['id']!, routeBase: routeBase),
      ),
      GoRoute(
        path: voiceCallPatternFor(routeBase),
        builder: (context, state) => VoiceCallScreen(consultationId: state.pathParameters['id']!, routeBase: routeBase),
      ),
      GoRoute(
        path: videoCallPatternFor(routeBase),
        builder: (context, state) => VideoCallScreen(consultationId: state.pathParameters['id']!, routeBase: routeBase),
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
  if (settle) {
    // Let the consultations-list + session `getSession` mock-latency
    // fetches resolve.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
  }
  return container;
}
