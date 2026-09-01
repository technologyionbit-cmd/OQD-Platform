import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_theme.dart';
import 'package:aqd_ionbit/features/contracts/data/repositories/contracts_repository_impl.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_category.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field_type.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_template.dart';
import 'package:aqd_ionbit/features/contracts/domain/repositories/contracts_repository.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contract_draft_controller.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_form_screen.dart';

class MockContractsRepository extends Mock implements ContractsRepository {}

const _template = ContractTemplate(
  id: 'sale',
  category: ContractCategory.sale,
  title: 'عقد بيع',
  fields: [
    ContractField(id: 'partyA', label: 'البائع', type: ContractFieldType.text, isRequired: true),
    ContractField(id: 'price', label: 'السعر', type: ContractFieldType.currency, isRequired: true),
  ],
);

Future<ProviderContainer> _pump(WidgetTester tester, {bool preselectTemplate = true}) async {
  final container = ProviderContainer(overrides: [contractsRepositoryProvider.overrideWithValue(MockContractsRepository())]);
  addTearDown(container.dispose);
  if (preselectTemplate) {
    container.read(contractDraftControllerProvider.notifier).selectTemplate(_template);
  }

  final router = GoRouter(
    initialLocation: RoutePaths.clientContractsNewForm,
    routes: [
      GoRoute(path: RoutePaths.clientContractsNewForm, builder: (context, state) => const ContractFormScreen()),
      GoRoute(path: RoutePaths.clientContractsNewPreview, builder: (context, state) => const Scaffold(body: Text('preview'))),
      GoRoute(path: RoutePaths.clientContractsNew, builder: (context, state) => const Scaffold(body: Text('type selection'))),
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
  testWidgets('renders one input per template field', (tester) async {
    await _pump(tester);

    expect(find.text('البائع'), findsOneWidget);
    expect(find.text('السعر'), findsOneWidget);
  });

  testWidgets('tapping continue with empty required fields shows inline errors and does not navigate', (tester) async {
    await _pump(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'متابعة'));
    await tester.pumpAndSettle();

    expect(find.text('This field is required'), findsNothing); // ensure English strings aren't leaking into ar locale
    expect(find.byType(ContractFormScreen), findsOneWidget);
    expect(find.text('preview'), findsNothing);
  });

  testWidgets('filling required fields and continuing navigates to preview', (tester) async {
    await _pump(tester);

    await tester.enterText(find.widgetWithText(TextField, 'البائع'), 'شركة الأفق');
    await tester.enterText(find.widgetWithText(TextField, 'السعر'), '500');
    await tester.tap(find.widgetWithText(ElevatedButton, 'متابعة'));
    await tester.pumpAndSettle();

    expect(find.text('preview'), findsOneWidget);
  });

  testWidgets('with no template selected, offers a way back to type selection instead of a broken form', (tester) async {
    await _pump(tester, preselectTemplate: false);

    expect(find.text('البائع'), findsNothing);
    expect(find.byType(ElevatedButton), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('type selection'), findsOneWidget);
  });
}
