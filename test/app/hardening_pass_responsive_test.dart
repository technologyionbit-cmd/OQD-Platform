import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';
import 'package:aqd_ionbit/core/theme/app_theme.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_data_source_provider.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_mock_data_source.dart';
import 'package:aqd_ionbit/features/lawyers/data/repositories/lawyers_repository_impl.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/verification_status.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/screens/lawyer_profile_edit_screen.dart';
import 'package:aqd_ionbit/features/notifications/presentation/screens/notifications_screen.dart';

import '../features/consultation_room/presentation/voice_call_test_support.dart';
import '../features/consultation_room/presentation/video_call_test_support.dart';
import '../features/messages/presentation/chat_room_test_support.dart'
    show FixedAuthController, SingleConsultationDataSource, pumpChatRoom, readyConsultation, testClient;

/// Focused responsive coverage for the screens this hardening pass actually
/// changed the layout of (a new dev-trigger icon in the call screens' AppBar
/// actions row, the chat "return to call" banner, the verification card +
/// upload button, the two AccountScreen rows growing a subtitle line) — the
/// existing `app_shell_responsive_test.dart` matrix only ever reaches
/// top-level shell routes, not these pushed/deep screens. Checks the four
/// breakpoints the hardening brief calls out: 320x568, 375x812, 430x932,
/// 1024x800.
const _sizes = {'320x568': Size(320, 568), '375x812': Size(375, 812), '430x932': Size(430, 932), '1024x800': Size(1024, 800)};

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpLawyerProfileEdit(WidgetTester tester, {required Locale locale}) async {
  final container = ProviderContainer(
    overrides: [lawyersRemoteDataSourceProvider.overrideWithValue(LawyersMockDataSource())],
  );
  addTearDown(container.dispose);

  // Unverified so the verification card + upload button (the new UI this
  // pass added) actually renders.
  await tester.runAsync(() async {
    final repo = container.read(lawyersRepositoryProvider);
    final current = (await repo.getLawyerById(kDemoLawyerId)).valueOrNull!;
    await repo.updateProfile(current.copyWith(verificationStatus: VerificationStatus.unverified));
  });

  final router = GoRouter(
    initialLocation: RoutePaths.lawyerProfileEdit,
    routes: [GoRoute(path: RoutePaths.lawyerProfileEdit, builder: (context, state) => const LawyerProfileEditScreen())],
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
  await tester.pumpAndSettle();
}

Future<void> _pumpNotifications(WidgetTester tester, {required Locale locale}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      authControllerProvider.overrideWith(() => FixedAuthController(testClient)),
      appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
    ],
  );
  addTearDown(container.dispose);
  await container.read(authControllerProvider.future);

  final router = GoRouter(
    initialLocation: RoutePaths.clientNotifications,
    routes: [GoRoute(path: RoutePaths.clientNotifications, builder: (context, state) => const NotificationsScreen())],
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
  await tester.pumpAndSettle();
}

void main() {
  for (final sizeEntry in _sizes.entries) {
    for (final locale in [const Locale('en'), const Locale('ar')]) {
      testWidgets('voice call screen (active, dev trigger visible) at ${sizeEntry.key} (${locale.languageCode})', (tester) async {
        _setSize(tester, sizeEntry.value);
        final consultation = voiceConsultation();
        await pumpVoiceCall(
          tester,
          user: testClient,
          consultationId: consultation.id,
          consultationsDataSource: SingleConsultationDataSource(consultation),
          locale: locale,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('video call screen (active, dev trigger visible) at ${sizeEntry.key} (${locale.languageCode})', (tester) async {
        _setSize(tester, sizeEntry.value);
        final consultation = videoConsultation();
        await pumpVideoCall(
          tester,
          user: testClient,
          consultationId: consultation.id,
          consultationsDataSource: SingleConsultationDataSource(consultation),
          locale: locale,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('written chat room (active) at ${sizeEntry.key} (${locale.languageCode})', (tester) async {
        _setSize(tester, sizeEntry.value);
        final consultation = readyConsultation(id: 'cons_responsive_chat');
        await pumpChatRoom(
          tester,
          user: testClient,
          consultationId: 'cons_responsive_chat',
          consultationsDataSource: SingleConsultationDataSource(consultation),
          locale: locale,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('lawyer profile edit (unverified, verification card visible) at ${sizeEntry.key} (${locale.languageCode})', (
        tester,
      ) async {
        _setSize(tester, sizeEntry.value);
        await _pumpLawyerProfileEdit(tester, locale: locale);
        expect(tester.takeException(), isNull);
      });

      testWidgets('notifications screen at ${sizeEntry.key} (${locale.languageCode})', (tester) async {
        _setSize(tester, sizeEntry.value);
        await _pumpNotifications(tester, locale: locale);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
