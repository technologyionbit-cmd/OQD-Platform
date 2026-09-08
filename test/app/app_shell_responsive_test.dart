import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/app/app_router.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contract_draft_controller.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contract_templates_provider.dart';

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
            // The account tab (kept alive alongside every other shell
            // branch by StatefulShellRoute.indexedStack) now watches
            // several mock-latency providers for its stats row. A bare
            // Future.delayed doesn't itself keep a frame scheduled, so
            // pumpAndSettle (which only keeps pumping while frames are
            // scheduled) can return before those futures resolve — drain
            // them explicitly first, in more than one jump since the
            // provider may not even be built yet on the very first pump.
            await tester.pump(const Duration(seconds: 1));
            await tester.pump(const Duration(seconds: 1));
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }

  // The contract sub-flow (form/preview/details) is pushed on top of the
  // client shell rather than being a shell branch, so it isn't covered by
  // the destinations map above — it still needs the same overflow coverage
  // since it's the deepest, most content-heavy part of the Phase 6 UI.
  for (final sizeEntry in _sizes.entries) {
    for (final locale in [const Locale('ar'), const Locale('en')]) {
      testWidgets('client contract form/preview render with no overflow at ${sizeEntry.key} (${locale.languageCode})', (tester) async {
        final harness = await pumpAuthenticatedApp(tester, user: testClient, size: sizeEntry.value, locale: locale);
        final container = harness.container;
        final router = container.read(routerProvider);

        // Riverpod's future here resolves via the mock data source's
        // simulated `Future.delayed` latency — the test clock is fake, so
        // it only advances on an explicit pump, not while bare-awaiting.
        final templatesFuture = container.read(contractTemplatesProvider.future);
        await tester.pump(const Duration(seconds: 1));
        final templates = await templatesFuture;
        final template = templates.first;
        final draftNotifier = container.read(contractDraftControllerProvider.notifier);
        draftNotifier.selectTemplate(template);

        router.go(RoutePaths.clientContractsNewForm);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        for (final field in template.fields) {
          draftNotifier.setFieldValue(field.id, field.type.name == 'dropdown' ? field.options.first : 'Test value');
        }

        router.go(RoutePaths.clientContractsNewPreview);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('client contract details renders with no overflow at ${sizeEntry.key} (${locale.languageCode})', (tester) async {
        final harness = await pumpAuthenticatedApp(tester, user: testClient, size: sizeEntry.value, locale: locale);
        final router = harness.container.read(routerProvider);

        router.go(RoutePaths.clientContractDetails('c_seed_1'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  }
}
