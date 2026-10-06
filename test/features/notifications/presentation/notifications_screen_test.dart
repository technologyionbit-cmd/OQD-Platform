
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';
import 'package:aqd_ionbit/core/theme/app_theme.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/app_notification.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';
import 'package:aqd_ionbit/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:aqd_ionbit/features/notifications/presentation/screens/notifications_screen.dart';

import '../../../support/role_test_harness.dart' show testClient, testLawyer;
import '../../../support/signed_in_override.dart';
import '../../../support/test_doubles.dart';

class MockNotificationsRepository extends Mock implements NotificationsRepository {}

final _requestNotification = AppNotification(
  id: 'n_request',
  type: NotificationType.consultationRequested,
  createdAt: DateTime(2026),
  relatedId: 'cons_1',
  params: const {'actorName': 'أحمد الخالدي'},
);

final _acceptedNotification = AppNotification(
  id: 'n_accepted',
  type: NotificationType.consultationAccepted,
  createdAt: DateTime(2026),
  relatedId: 'cons_1',
  params: const {'actorName': 'سارة المطيري'},
);

/// No related entity, so there is nowhere to go.
final _orphanNotification = AppNotification(
  id: 'n_orphan',
  type: NotificationType.consultationCancelled,
  createdAt: DateTime(2026),
  params: const {'actorName': 'سارة المطيري'},
);

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required AuthUser user,
  required MockNotificationsRepository repository,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [signedInOverride, 
      authControllerProvider.overrideWith(() => FixedAuthController(user)),
      notificationsRepositoryProvider.overrideWithValue(repository),
      // NotificationsScreen now also renders the push-notifications toggle
      // (moved here from AccountScreen), which reads this.
      appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
    ],
  );
  addTearDown(container.dispose);
  // Nothing in NotificationsScreen's build() watches authControllerProvider
  // (only _handleTap reads it, lazily, on tap) — force it to resolve now so
  // the read on tap isn't racing the notifier's own async build().
  await container.read(authControllerProvider.future);

  final router = GoRouter(
    initialLocation: RoutePaths.lawyerNotifications,
    routes: [
      GoRoute(path: RoutePaths.lawyerNotifications, builder: (context, state) => const NotificationsScreen()),
      GoRoute(
        path: RoutePaths.lawyerConsultationDetailsPattern,
        builder: (context, state) => Scaffold(body: Text('lawyer-consultation-${state.pathParameters['id']}')),
      ),
      GoRoute(
        path: RoutePaths.clientConsultationDetailsPattern,
        builder: (context, state) => Scaffold(body: Text('client-consultation-${state.pathParameters['id']}')),
      ),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: AppTheme.light,
        locale: const Locale('ar'),
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
  testWidgets('builds the text in the current language from the type and params', (tester) async {
    final repository = MockNotificationsRepository();
    when(repository.getNotifications).thenAnswer((_) async => Result.success([_requestNotification]));

    await _pump(tester, user: testLawyer, repository: repository);

    expect(find.text('طلب استشارة جديد'), findsOneWidget);
    expect(find.text('أرسل لك أحمد الخالدي طلب استشارة'), findsOneWidget);
  });

  testWidgets('a lawyer tapping a request opens her own consultation details', (tester) async {
    final repository = MockNotificationsRepository();
    when(repository.getNotifications).thenAnswer((_) async => Result.success([_requestNotification]));
    when(() => repository.markAsRead('n_request')).thenAnswer((_) async => const Result.success(null));

    await _pump(tester, user: testLawyer, repository: repository);

    await tester.tap(find.text('طلب استشارة جديد'));
    await tester.pumpAndSettle();

    expect(find.text('lawyer-consultation-cons_1'), findsOneWidget);
    verify(() => repository.markAsRead('n_request')).called(1);
  });

  testWidgets('a client tapping an acceptance opens the client consultation details', (tester) async {
    final repository = MockNotificationsRepository();
    when(repository.getNotifications).thenAnswer((_) async => Result.success([_acceptedNotification]));
    when(() => repository.markAsRead('n_accepted')).thenAnswer((_) async => const Result.success(null));

    await _pump(tester, user: testClient, repository: repository);

    await tester.tap(find.text('تم قبول طلب الاستشارة'));
    await tester.pumpAndSettle();

    expect(find.text('client-consultation-cons_1'), findsOneWidget);
  });

  testWidgets('tapping a notification with nowhere to go still marks it read and says so', (tester) async {
    final repository = MockNotificationsRepository();
    when(repository.getNotifications).thenAnswer((_) async => Result.success([_orphanNotification]));
    when(() => repository.markAsRead('n_orphan')).thenAnswer((_) async => const Result.success(null));

    await _pump(tester, user: testClient, repository: repository);

    await tester.tap(find.text('تم إلغاء الاستشارة'));
    await tester.pumpAndSettle();

    expect(find.text('هذا الإشعار غير متاح من حسابك الحالي'), findsOneWidget);
    verify(() => repository.markAsRead('n_orphan')).called(1);
  });
}
