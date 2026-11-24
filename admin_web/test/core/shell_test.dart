import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_admin/core/layout/admin_shell.dart';
import 'package:aqd_admin/core/layout/layout_providers.dart';
import 'package:aqd_admin/core/layout/sidebar.dart';
import 'package:aqd_admin/core/routing/nav_items.dart';
import 'package:aqd_admin/core/routing/route_paths.dart';
import 'package:aqd_admin/features/auth/domain/admin_user.dart';
import 'package:aqd_admin/features/auth/presentation/providers/auth_controller.dart';

import '../support/test_app.dart';

class _SignedIn extends AuthController {
  @override
  Future<AdminUser?> build() async => const AdminUser(id: '1', fullName: 'Aqd Admin', email: 'a@a.com', role: 'admin', fullAccess: true);
}

Future<void> pumpShell(WidgetTester tester, {required Size size}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    testApp(
      const AdminShell(location: RoutePaths.users, child: Text('BODY')),
      overrides: [authControllerProvider.overrideWith(_SignedIn.new)],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('every nav item belongs to its own location and sub-locations', () {
    expect(navItemFor(RoutePaths.users)?.path, RoutePaths.users);
    expect(navItemFor('${RoutePaths.users}/123')?.path, RoutePaths.users);
    expect(navItemFor('/usersx'), isNull);
    expect(navItemFor('/unknown'), isNull);
  });

  testWidgets('wide screen: sidebar with all modules, breadcrumbs, user menu', (tester) async {
    await pumpShell(tester, size: const Size(1400, 900));

    expect(find.byType(Sidebar), findsOneWidget);
    for (final label in ['Dashboard', 'Users', 'Lawyer verification', 'Lawyers', 'Companies', 'Consultations', 'Contracts', 'Government procedures', 'Notifications', 'Audit log', 'Settings']) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('BODY'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsNothing);
  });

  testWidgets('the sidebar folds down to icons and back', (tester) async {
    await pumpShell(tester, size: const Size(1400, 900));
    expect(tester.getSize(find.byType(AnimatedContainer).first).width, sidebarWidth);

    await tester.tap(find.byTooltip('Collapse menu'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(AnimatedContainer).first).width, sidebarCollapsedWidth);
    expect(tester.element(find.byType(Sidebar)).findAncestorWidgetOfExactType<ProviderScope>(), isNotNull);

    await tester.tap(find.byTooltip('Expand menu'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(AnimatedContainer).first).width, sidebarWidth);
  });

  testWidgets('narrow screen: the sidebar is a drawer behind the menu button', (tester) async {
    await pumpShell(tester, size: const Size(700, 900));
    expect(find.byType(Sidebar), findsNothing);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.byType(Sidebar), findsOneWidget);
    expect(find.text('Users'), findsWidgets);
  });

  testWidgets('sidebarCollapsedProvider toggles', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(sidebarCollapsedProvider), isFalse);
    container.read(sidebarCollapsedProvider.notifier).toggle();
    expect(container.read(sidebarCollapsedProvider), isTrue);
  });
}
