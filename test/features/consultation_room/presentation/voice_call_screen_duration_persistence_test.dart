import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_theme.dart';
import 'package:aqd_ionbit/features/consultation_room/presentation/screens/voice_call_screen.dart';

import '../../messages/presentation/chat_room_test_support.dart' show SingleConsultationDataSource, testClient;
import 'consultation_waiting_screen_test_support.dart' show consultationDetailsPatternFor, voiceCallPatternFor;
import 'voice_call_test_support.dart';

/// Proves the call duration lives on `SessionController`/`CallMetrics`
/// (see `SessionController.incrementDuration`), not widget-local `State` —
/// it must keep counting from where it left off across the *screen* being
/// disposed and recreated (e.g. navigating away and back), rather than
/// resetting to `00:00`.
void main() {
  Future<void> pumpFreshVoiceCallScreen(WidgetTester tester, ProviderContainer container, String consultationId) async {
    final router = GoRouter(
      initialLocation: RoutePaths.voiceCallFor(RoutePaths.clientBase, consultationId),
      routes: [
        GoRoute(
          path: voiceCallPatternFor(RoutePaths.clientBase),
          builder: (context, state) => VoiceCallScreen(consultationId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: consultationDetailsPatternFor(RoutePaths.clientBase),
          builder: (context, state) => const Scaffold(body: Text('details screen')),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light,
          // Assertions below are written against the English strings.
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
  }

  testWidgets('duration keeps counting from where it left off after the call screen is disposed and recreated', (tester) async {
    final consultation = voiceConsultation();
    final container = await pumpVoiceCall(
      tester,
      user: testClient,
      consultationId: consultation.id,
      consultationsDataSource: SingleConsultationDataSource(consultation),
    );
    expect(find.text('Connected'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    final durationPattern = RegExp(r'^\d{2}:\d{2}$');
    String currentDurationText() =>
        tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).whereType<String>().firstWhere(durationPattern.hasMatch);
    final beforeRebuild = currentDurationText();
    expect(beforeRebuild, isNot('00:00'));

    // Tear down the entire widget tree (simulating the screen being
    // disposed, e.g. by navigating away) — the session/duration must live
    // on in the still-alive container, not in the now-gone widget State.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    // Recreate the same screen fresh, against the SAME container/session.
    await pumpFreshVoiceCallScreen(tester, container, consultation.id);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Connected'), findsOneWidget);
    final afterRebuild = currentDurationText();
    final beforeSeconds = int.parse(beforeRebuild.split(':').last);
    final afterSeconds = int.parse(afterRebuild.split(':').last);
    expect(afterSeconds, greaterThanOrEqualTo(beforeSeconds), reason: 'duration must not reset to 00:00 after the screen is recreated');
  });
}
