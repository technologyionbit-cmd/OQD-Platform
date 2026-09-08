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
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/notifications/data/datasources/notifications_data_source_provider.dart';
import 'package:aqd_ionbit/features/notifications/data/datasources/notifications_mock_data_source.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';
import 'package:aqd_ionbit/features/notifications/presentation/providers/notifications_controller.dart';
import 'package:aqd_ionbit/features/notifications/presentation/screens/notifications_screen.dart';

import '../../messages/presentation/chat_room_test_support.dart' show FixedAuthController, testClient, testLawyer;

/// Exercises the *real*, shared `NotificationsMockDataSource` across two
/// simulated auth sessions (not two independently-stubbed mocks) — the gap
/// the previous coverage had, per the exploration that drove this fix: any
/// role-scoped fix needs to prove a lawyer's list actually excludes
/// client-only notifications from the same underlying store, not just that
/// a hand-picked list renders correctly for one role in isolation.
Future<ProviderContainer> _pumpFor(
  WidgetTester tester, {
  required AuthUser user,
  required NotificationsMockDataSource dataSource,
  required String route,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      authControllerProvider.overrideWith(() => FixedAuthController(user)),
      notificationsRemoteDataSourceProvider.overrideWithValue(dataSource),
      appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
    ],
  );
  addTearDown(container.dispose);
  await container.read(authControllerProvider.future);

  final router = GoRouter(
    initialLocation: route,
    routes: [
      GoRoute(path: RoutePaths.clientNotifications, builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: RoutePaths.lawyerNotifications, builder: (context, state) => const NotificationsScreen()),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.light,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('a client sees the seeded client notifications but not a lawyer-only one', (tester) async {
    final dataSource = NotificationsMockDataSource();
    // Simulate a lawyer-only notification already sitting in the shared
    // store before the client ever opens their notification center.
    // `runAsync` escapes the fake-async zone `testWidgets` runs in: a bare
    // `await` on the mock's simulated latency here (before any
    // `tester.pump()` has driven the fake clock forward) would hang.
    await tester.runAsync(
      () => dataSource.create(
        type: NotificationType.newMessage,
        title: 'رسالة من العميل',
        body: 'رسالة تخص المحامية فقط',
        recipientUserId: kDemoLawyerUserId,
      ),
    );

    await _pumpFor(tester, user: testClient, dataSource: dataSource, route: RoutePaths.clientNotifications);

    expect(find.text('موعد استشارة قريب'), findsOneWidget); // seeded, recipientUserId: client
    expect(find.text('عقدك جاهز'), findsOneWidget); // seeded, recipientUserId: client
    expect(find.text('رسالة من العميل'), findsNothing, reason: 'a lawyer-only notification must not show up for the client');
  });

  testWidgets('a lawyer sees a lawyer-only notification but none of the seeded client-only ones', (tester) async {
    final dataSource = NotificationsMockDataSource();
    await tester.runAsync(
      () => dataSource.create(
        type: NotificationType.newMessage,
        title: 'رسالة من العميل',
        body: 'رسالة تخص المحامية فقط',
        recipientUserId: kDemoLawyerUserId,
      ),
    );

    await _pumpFor(tester, user: testLawyer, dataSource: dataSource, route: RoutePaths.lawyerNotifications);

    expect(find.text('رسالة من العميل'), findsOneWidget);
    expect(find.text('موعد استشارة قريب'), findsNothing, reason: 'a client-only seeded notification must not show up for the lawyer');
    expect(find.text('عقدك جاهز'), findsNothing);
    expect(find.text('تم رفع مستند'), findsNothing);
  });

  testWidgets('the unread badge count is scoped per role too', (tester) async {
    final dataSource = NotificationsMockDataSource();
    await tester.runAsync(
      () => dataSource.create(
        type: NotificationType.newMessage,
        title: 'رسالة من العميل',
        body: 'رسالة تخص المحامية فقط',
        recipientUserId: kDemoLawyerUserId,
      ),
    );

    final lawyerContainer = await _pumpFor(tester, user: testLawyer, dataSource: dataSource, route: RoutePaths.lawyerNotifications);

    // Only the one lawyer-scoped notification just created counts toward
    // the lawyer's own unread badge — none of the 5 client-scoped seeds do.
    expect(lawyerContainer.read(unreadNotificationsCountProvider), 1);
  });
}
