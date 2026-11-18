import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/config/feature_flags.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations_ar.dart';
import 'package:aqd_ionbit/core/routing/app_router.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/company/presentation/screens/company_home_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/help_support_screen.dart';

import 'package:aqd_ionbit/features/home/presentation/screens/client_home_screen.dart';

import '../support/role_test_harness.dart';

Finder _navLabel(String label) {
  final navChrome = find.byWidgetPredicate((widget) => widget is NavigationBar || widget is NavigationRail);
  return find.descendant(of: navChrome, matching: find.text(label));
}

/// Release builds hide the features that run on made-up data (AI, document
/// vault) so users never see invented results.
void main() {
  testWidgets('release layout: client shell has no AI or Documents tab', (tester) async {
    await pumpAuthenticatedApp(tester, user: testClient, size: const Size(400, 900), previewFeatures: false);

    expect(find.byType(ClientHomeScreen), findsOneWidget);
    for (final label in ['الرئيسية', 'المحامون', 'حسابي']) {
      expect(_navLabel(label), findsOneWidget, reason: 'missing nav label "$label"');
    }
    for (final label in ['AI', 'المستندات']) {
      expect(_navLabel(label), findsNothing, reason: 'preview tab "$label" must be hidden');
    }
    expect(find.byType(NavigationDestination), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('release layout: home hides the contract-analysis tile and the vault banner', (tester) async {
    await pumpAuthenticatedApp(tester, user: testClient, size: const Size(400, 900), previewFeatures: false);

    expect(find.byIcon(Icons.smart_toy_outlined), findsNothing);
    expect(find.byIcon(Icons.search_outlined), findsNothing);
    expect(find.byIcon(Icons.folder_outlined), findsNothing);
  });

  testWidgets('preview layout keeps all five client tabs', (tester) async {
    await pumpAuthenticatedApp(tester, user: testClient, size: const Size(400, 900), previewFeatures: true);

    expect(find.byType(NavigationDestination), findsNWidgets(5));
  });

  // --- FE-01b: everything else that runs on made-up data ------------------

  test('isPreviewOnlyRoute covers the mock-only screens and nothing real', () {
    for (final path in [
      '/client/ai',
      '/client/ai/chat',
      '/client/ai/analysis/42',
      '/client/documents',
      '/lawyer/documents',
      '/company/documents',
      '/company/team',
      '/company/team/m1',
      '/client/consultations/abc/chat',
      '/lawyer/consultations/abc/chat',
      '/client/subscription',
      '/company/account/invoices',
      '/client/account/payment-methods',
      '/lawyer/account/signature',
    ]) {
      expect(isPreviewOnlyRoute(path), isTrue, reason: path);
    }
    for (final path in [
      '/client/home',
      '/client/lawyers',
      '/client/lawyers/abc',
      '/client/consultations',
      '/client/consultations/abc',
      '/client/consultations/abc/room',
      '/client/contracts/details/9',
      '/client/account/help',
      '/company/contracts',
    ]) {
      expect(isPreviewOnlyRoute(path), isFalse, reason: path);
    }
  });

  testWidgets('release layout: a company has no Documents tab, no documents/team cards and no add-member action', (tester) async {
    await pumpAuthenticatedApp(tester, user: testCompany, size: const Size(400, 900), previewFeatures: false);

    expect(find.byType(CompanyHomeScreen), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(_navLabel(AppLocalizationsAr().navDocuments), findsNothing);
    expect(find.byIcon(Icons.groups_outlined), findsNothing);
    expect(find.byIcon(Icons.person_add_outlined), findsNothing);
    // Real features stay.
    expect(find.byIcon(Icons.description_outlined), findsWidgets);
    expect(find.byIcon(Icons.event_note_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preview layout keeps the company Documents tab and cards', (tester) async {
    await pumpAuthenticatedApp(tester, user: testCompany, size: const Size(400, 900), previewFeatures: true);

    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.byIcon(Icons.groups_outlined), findsOneWidget);
  });

  testWidgets('release: typed/stale links to mock-only screens land on the role home', (tester) async {
    final harness = await pumpAuthenticatedApp(tester, user: testCompany, size: const Size(400, 900), previewFeatures: false);
    final router = harness.container.read(routerProvider);

    for (final path in [RoutePaths.companyTeam, RoutePaths.companyDocuments, '/company/consultations/c1/chat']) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(find.byType(CompanyHomeScreen), findsOneWidget, reason: '$path must redirect to the company home');
    }
  });

  testWidgets('release: a client deep link to the AI tab or chat lands on the client home', (tester) async {
    final harness = await pumpAuthenticatedApp(tester, user: testClient, size: const Size(400, 900), previewFeatures: false);
    final router = harness.container.read(routerProvider);

    for (final path in [RoutePaths.clientAi, '/client/consultations/c1/chat']) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(find.byType(ClientHomeScreen), findsOneWidget, reason: '$path must redirect to the client home');
    }
  });

  Future<void> pumpHelp(WidgetTester tester, {required bool preview}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [previewFeaturesProvider.overrideWithValue(preview)],
        child: const MaterialApp(
          locale: Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HelpSupportScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('release: help & support keeps the FAQ but not the mock contact form', (tester) async {
    await pumpHelp(tester, preview: false);

    expect(find.text(AppLocalizationsAr().helpFaqTitle), findsOneWidget);
    expect(find.text(AppLocalizationsAr().helpContactUs), findsNothing);
  });

  testWidgets('preview: help & support still offers the contact form', (tester) async {
    await pumpHelp(tester, preview: true);

    expect(find.text(AppLocalizationsAr().helpContactUs), findsOneWidget);
  });
}
