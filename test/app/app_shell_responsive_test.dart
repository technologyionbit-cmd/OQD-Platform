import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/app/app_router.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';

import '../support/role_test_harness.dart';

// Required by Phase 5 step 8 (extended in Phase 6 to add the mid-range
// phone size): smallest and largest realistic phone widths, a common
// mid-size phone, plus a tablet/desktop width that should trigger the
// NavigationRail layout.
const _sizes = {
  'small phone': Size(320, 568),
  'mid phone': Size(390, 844),
  'large phone': Size(430, 932),
  'tablet': Size(1024, 800),
};

void main() {
  final destinations = <String, ({AuthUser user, List<String> routes})>{
    'client': (
      user: testClient,
      routes: [
        RoutePaths.clientHome,
        RoutePaths.clientAi,
        RoutePaths.clientDocuments,
        RoutePaths.clientContracts,
        RoutePaths.clientContractsNew,
        RoutePaths.clientAccount,
      ],
    ),
    'lawyer': (user: testLawyer, routes: [RoutePaths.lawyerDashboard, RoutePaths.lawyerSchedule, RoutePaths.lawyerProfile]),
    'company': (user: testCompany, routes: [RoutePaths.companyHome, RoutePaths.companyContracts, RoutePaths.companyAccount]),
  };

  for (final roleEntry in destinations.entries) {
    for (final route in roleEntry.value.routes) {
      for (final sizeEntry in _sizes.entries) {
        for (final locale in [const Locale('ar'), const Locale('en')]) {
          testWidgets('${roleEntry.key} $route renders with no overflow at ${sizeEntry.key} (${locale.languageCode})', (tester) async {
            final harness = await pumpAuthenticatedApp(tester, user: roleEntry.value.user, size: sizeEntry.value, locale: locale);
            harness.container.read(routerProvider).go(route);
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }
}
