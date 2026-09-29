import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/localization/locale_controller.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_theme.dart';
import 'package:aqd_ionbit/features/contracts/data/repositories/contracts_repository_impl.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_category.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field_type.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_template.dart';
import 'package:aqd_ionbit/features/contracts/domain/repositories/contracts_repository.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contract_draft_controller.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_type_selection_screen.dart';
import '../../../support/signed_in_override.dart';

class MockContractsRepository extends Mock implements ContractsRepository {}

class _FixedLocaleController extends LocaleController {
  @override
  Locale build() => const Locale('ar');
}

final _templates = [
  const ContractTemplate(
    id: 'employment',
    category: ContractCategory.employment,
    title: 'عقد عمل',
    fields: [ContractField(id: 'partyA', label: 'الطرف الأول', type: ContractFieldType.text, isRequired: true)],
  ),
  const ContractTemplate(
    id: 'sale',
    category: ContractCategory.sale,
    title: 'عقد بيع',
    fields: [ContractField(id: 'partyA', label: 'البائع', type: ContractFieldType.text, isRequired: true)],
  ),
];

Future<ProviderContainer> _pump(WidgetTester tester) async {
  final repository = MockContractsRepository();
  when(() => repository.getTemplates(locale: any(named: 'locale'))).thenAnswer((_) async => Result.success(_templates));

  final container = ProviderContainer(
    overrides: [signedInOverride, 
      contractsRepositoryProvider.overrideWithValue(repository),
      localeControllerProvider.overrideWith(_FixedLocaleController.new),
    ],
  );
  addTearDown(container.dispose);

  // A real GoRouter, not a plain MaterialApp — the screen calls
  // `context.push` on continue, which needs an ancestor GoRouter to resolve.
  final router = GoRouter(
    initialLocation: RoutePaths.clientContractsNew,
    routes: [
      GoRoute(path: RoutePaths.clientContractsNew, builder: (context, state) => const ContractTypeSelectionScreen()),
      GoRoute(path: RoutePaths.clientContractsNewForm, builder: (context, state) => const Scaffold(body: Text('form'))),
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
  setUpAll(() {
    registerFallbackValue(const Locale('ar'));
  });

  testWidgets('renders every template as a selectable card', (tester) async {
    await _pump(tester);

    expect(find.text('عقد عمل'), findsOneWidget);
    expect(find.text('عقد بيع'), findsOneWidget);
  });

  testWidgets('continue is disabled until a template is selected, then loads it into the draft controller', (tester) async {
    final container = await _pump(tester);

    final continueButton = find.widgetWithText(ElevatedButton, 'متابعة');
    expect(tester.widget<ElevatedButton>(continueButton).onPressed, isNull);

    await tester.tap(find.text('عقد بيع'));
    await tester.pumpAndSettle();

    expect(tester.widget<ElevatedButton>(continueButton).onPressed, isNotNull);

    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(container.read(contractDraftControllerProvider).template?.id, 'sale');
  });

  testWidgets('search narrows the visible templates', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'بيع');
    await tester.pumpAndSettle();

    expect(find.text('عقد بيع'), findsOneWidget);
    expect(find.text('عقد عمل'), findsNothing);
  });
}
