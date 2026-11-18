
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aqd_ionbit/app.dart';
import 'package:aqd_ionbit/core/routing/app_router.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/login_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/welcome_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:aqd_ionbit/features/company/presentation/screens/company_home_screen.dart';
import 'package:aqd_ionbit/features/home/presentation/screens/client_home_screen.dart';
import 'package:aqd_ionbit/features/lawyer_dashboard/presentation/screens/lawyer_dashboard_screen.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_data_source_provider.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_mock_data_source.dart';

import '../support/role_test_harness.dart';

void main() {
  Future<ProviderContainer> pumpGuestApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'prefs.onboarding_seen': true});
    final prefs = await SharedPreferences.getInstance();
    final tokenManager = MockTokenManager();
    when(tokenManager.loadFromStorage).thenAnswer((_) async => null);
    when(() => tokenManager.current).thenReturn(null);

    final container = ProviderContainer(
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        tokenManagerProvider.overrideWithValue(tokenManager),
        // Keep the guest home's lawyer list off the network.
        lawyersRemoteDataSourceProvider.overrideWithValue(LawyersMockDataSource()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const AqdApp()));
    await tester.pumpAndSettle();
    return container;
  }

  group('signed out (onboarding seen)', () {
    testWidgets('lands on the welcome page after loading, never on the home', (tester) async {
      await pumpGuestApp(tester);

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.byType(ClientHomeScreen), findsNothing);
    });

    testWidgets('cannot open the lawyers list or any other app route without an account', (tester) async {
      final container = await pumpGuestApp(tester);

      for (final route in [RoutePaths.clientHome, RoutePaths.clientLawyers, RoutePaths.clientContractsNew, RoutePaths.lawyerDashboard]) {
        container.read(routerProvider).go(route);
        await tester.pumpAndSettle();
        expect(find.byType(WelcomeScreen), findsOneWidget, reason: route);
      }
      expect(find.byType(LawyerDashboardScreen), findsNothing);
    });

    testWidgets('the welcome page opens the login page', (tester) async {
      await pumpGuestApp(tester);

      GoRouter.of(tester.element(find.byType(WelcomeScreen))).go(RoutePaths.login);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('authenticated client', () {
    testWidgets('lands on the client home after login', (tester) async {
      await pumpAuthenticatedApp(tester, user: testClient);

      expect(find.byType(ClientHomeScreen), findsOneWidget);
    });

    testWidgets('cannot open lawyer or company routes and is bounced back to client home', (tester) async {
      final harness = await pumpAuthenticatedApp(tester, user: testClient);

      harness.container.read(routerProvider).go(RoutePaths.lawyerDashboard);
      await tester.pumpAndSettle();
      expect(find.byType(LawyerDashboardScreen), findsNothing);
      expect(find.byType(ClientHomeScreen), findsOneWidget);

      harness.container.read(routerProvider).go(RoutePaths.companyHome);
      await tester.pumpAndSettle();
      expect(find.byType(CompanyHomeScreen), findsNothing);
      expect(find.byType(ClientHomeScreen), findsOneWidget);
    });
  });

  group('authenticated lawyer', () {
    testWidgets('lands on the lawyer dashboard after login', (tester) async {
      await pumpAuthenticatedApp(tester, user: testLawyer);

      expect(find.byType(LawyerDashboardScreen), findsOneWidget);
    });

    testWidgets('cannot open client or company routes and is bounced back to the dashboard', (tester) async {
      final harness = await pumpAuthenticatedApp(tester, user: testLawyer);

      harness.container.read(routerProvider).go(RoutePaths.clientHome);
      await tester.pumpAndSettle();
      expect(find.byType(ClientHomeScreen), findsNothing);
      expect(find.byType(LawyerDashboardScreen), findsOneWidget);

      harness.container.read(routerProvider).go(RoutePaths.companyHome);
      await tester.pumpAndSettle();
      expect(find.byType(CompanyHomeScreen), findsNothing);
      expect(find.byType(LawyerDashboardScreen), findsOneWidget);
    });
  });

  group('authenticated company', () {
    testWidgets('lands on the company home after login', (tester) async {
      await pumpAuthenticatedApp(tester, user: testCompany);

      expect(find.byType(CompanyHomeScreen), findsOneWidget);
    });

    testWidgets('cannot open client or lawyer routes and is bounced back to company home', (tester) async {
      final harness = await pumpAuthenticatedApp(tester, user: testCompany);

      harness.container.read(routerProvider).go(RoutePaths.clientHome);
      await tester.pumpAndSettle();
      expect(find.byType(ClientHomeScreen), findsNothing);
      expect(find.byType(CompanyHomeScreen), findsOneWidget);

      harness.container.read(routerProvider).go(RoutePaths.lawyerDashboard);
      await tester.pumpAndSettle();
      expect(find.byType(LawyerDashboardScreen), findsNothing);
      expect(find.byType(CompanyHomeScreen), findsOneWidget);
    });

    testWidgets('is redirected away from login/onboarding back to their own home', (tester) async {
      final harness = await pumpAuthenticatedApp(tester, user: testCompany);

      harness.container.read(routerProvider).go(RoutePaths.login);
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(CompanyHomeScreen), findsOneWidget);
    });
  });
}
