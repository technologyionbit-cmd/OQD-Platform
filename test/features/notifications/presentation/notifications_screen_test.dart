import 'dart:async';

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

class MockNotificationsRepository extends Mock implements NotificationsRepository {}

/// Overrides [AuthController.build] so a test can pin the signed-in role
/// directly instead of driving the login flow to get there.
class FixedAuthController extends AuthController {
  FixedAuthController(this._user);
  final AuthUser _user;

  @override
  FutureOr<AuthUser?> build() async => _user;
}

final _contractReadyNotification = AppNotification(
  id: 'n_seed_2',
  type: NotificationType.contractReady,
  title: 'عقدك جاهز',
  body: 'تم إنشاء العقد بنجاح',
  createdAt: DateTime(2026),
  relatedId: 'c_seed_1',
);

/// AI contract analysis is only ever a client-facing surface — this is the
/// one notification type genuinely has no destination for the lawyer role,
/// used below to keep exercising the "no destination" fallback now that
/// contract/document notifications route correctly for a lawyer too.
final _aiAnalysisNotification = AppNotification(
  id: 'n_seed_ai',
  type: NotificationType.aiAnalysisCompleted,
  title: 'اكتمل تحليل العقد',
  body: 'تم الانتهاء من تحليل العقد',
  createdAt: DateTime(2026),
  relatedId: 'c_seed_1',
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
        path: RoutePaths.lawyerContractDetailsPattern,
        builder: (context, state) => const Scaffold(body: Text('contract-details')),
      ),
      GoRoute(
        path: RoutePaths.clientContractDetailsPattern,
        builder: (context, state) => const Scaffold(body: Text('contract-details')),
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
  // A lawyer only ever gets AI contract-analysis notifications generated
  // for the client — that type has no lawyer-side screen at all, so this is
  // the genuine "no destination" case. Tapping it must still give feedback
  // instead of silently doing nothing.
  testWidgets('tapping a notification with no destination for the current role shows a fallback message', (tester) async {
    final repository = MockNotificationsRepository();
    when(repository.getNotifications).thenAnswer((_) async => Result.success([_aiAnalysisNotification]));
    when(() => repository.markAsRead('n_seed_ai')).thenAnswer((_) async => const Result.success(null));

    await _pump(tester, user: testLawyer, repository: repository);

    await tester.tap(find.text('اكتمل تحليل العقد'));
    await tester.pumpAndSettle();

    expect(find.text('contract-details'), findsNothing);
    expect(find.text('هذا الإشعار غير متاح من حسابك الحالي'), findsOneWidget);
    verify(() => repository.markAsRead('n_seed_ai')).called(1);
  });

  testWidgets('tapping a notification with a valid destination navigates there', (tester) async {
    final repository = MockNotificationsRepository();
    when(repository.getNotifications).thenAnswer((_) async => Result.success([_contractReadyNotification]));
    when(() => repository.markAsRead('n_seed_2')).thenAnswer((_) async => const Result.success(null));

    await _pump(tester, user: testClient, repository: repository);

    await tester.tap(find.text('عقدك جاهز'));
    await tester.pumpAndSettle();

    expect(find.text('contract-details'), findsOneWidget);
  });

  // Regression coverage for the fix: a lawyer can read a client's contract
  // (lawyerContractDetailsPattern exists and is registered), so a contract
  // notification must actually take her there instead of the old
  // unconditional null for the lawyer role.
  testWidgets('a lawyer tapping a contract notification navigates to her own contract-details route', (tester) async {
    final repository = MockNotificationsRepository();
    when(repository.getNotifications).thenAnswer((_) async => Result.success([_contractReadyNotification]));
    when(() => repository.markAsRead('n_seed_2')).thenAnswer((_) async => const Result.success(null));

    await _pump(tester, user: testLawyer, repository: repository);

    await tester.tap(find.text('عقدك جاهز'));
    await tester.pumpAndSettle();

    expect(find.text('contract-details'), findsOneWidget);
  });
}
