import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/features/auth/presentation/screens/login_screen.dart';
import 'package:aqd_ionbit/features/company/presentation/screens/company_home_screen.dart';
import 'package:aqd_ionbit/features/home/presentation/screens/client_home_screen.dart';
import 'package:aqd_ionbit/features/lawyer_dashboard/presentation/screens/lawyer_dashboard_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/account_screen.dart';

import '../support/role_test_harness.dart';

/// Client/company home now surface real content, which legitimately reuses
/// some of the same words as their own nav labels (a "Documents" service
/// shortcut card living on a screen next to a "Documents" nav tab, say) —
/// so nav-label presence must be checked within the nav chrome itself
/// (`NavigationBar` or `NavigationRail`, whichever the layout is using)
/// rather than anywhere on screen.
Finder _navLabel(String label) {
  final navChrome = find.byWidgetPredicate((widget) => widget is NavigationBar || widget is NavigationRail);
  return find.descendant(of: navChrome, matching: find.text(label));
}

void main() {
  testWidgets('client shell renders with a 5-item bottom nav and no exceptions', (tester) async {
    await pumpAuthenticatedApp(tester, user: testClient);

    expect(find.byType(ClientHomeScreen), findsOneWidget);
    for (final label in ['الرئيسية', 'AI', 'المستندات', 'المحامون', 'حسابي']) {
      expect(_navLabel(label), findsOneWidget, reason: 'missing client nav label "$label"');
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('lawyer shell renders with a 5-item bottom nav and no exceptions', (tester) async {
    await pumpAuthenticatedApp(tester, user: testLawyer);

    expect(find.byType(LawyerDashboardScreen), findsOneWidget);
    for (final label in ['لوحة التحكم', 'المواعيد', 'العملاء', 'الأرباح', 'ملفي']) {
      expect(_navLabel(label), findsOneWidget, reason: 'missing lawyer nav label "$label"');
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('company shell renders with a 5-item bottom nav and no exceptions', (tester) async {
    await pumpAuthenticatedApp(tester, user: testCompany);

    expect(find.byType(CompanyHomeScreen), findsOneWidget);
    for (final label in ['الرئيسية', 'العقود', 'المحامون', 'المستندات', 'حسابي']) {
      expect(_navLabel(label), findsOneWidget, reason: 'missing company nav label "$label"');
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the account tab navigates to AccountScreen and logout is available', (tester) async {
    await pumpAuthenticatedApp(tester, user: testClient);

    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();

    expect(find.byType(AccountScreen), findsOneWidget);
    expect(find.text('تسجيل الخروج'), findsOneWidget);
  });

  testWidgets('logout requires confirmation and returns to the login screen once confirmed', (tester) async {
    await pumpAuthenticatedApp(tester, user: testClient);

    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('تسجيل الخروج').first);
    await tester.pumpAndSettle();

    // A confirmation dialog stands between the tap and an actual sign-out.
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);

    await tester.tap(find.text('تسجيل الخروج').last);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  group('responsive shell chrome', () {
    testWidgets('uses a bottom NavigationBar on phone widths', (tester) async {
      await pumpAuthenticatedApp(tester, user: testClient, size: const Size(390, 844));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('switches to a side NavigationRail on tablet/desktop widths', (tester) async {
      await pumpAuthenticatedApp(tester, user: testClient, size: const Size(1024, 800));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });
}
