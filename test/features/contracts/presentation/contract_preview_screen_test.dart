import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aqd_ionbit/core/localization/locale_controller.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_theme.dart';
import 'package:aqd_ionbit/features/contracts/data/repositories/contracts_repository_impl.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_category.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field_type.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_status.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_template.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contract_draft_controller.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_preview_screen.dart';
import '../../../support/signed_in_override.dart';
import '../../../support/role_test_harness.dart' show FixedLocaleController;
import '../../../support/test_doubles.dart';

const _template = ContractTemplate(
  id: 'sale',
  category: ContractCategory.sale,
  title: 'عقد بيع',
  fields: [
    ContractField(id: 'partyA', label: 'البائع', type: ContractFieldType.text, isRequired: true),
    ContractField(id: 'partyB', label: 'المشتري', type: ContractFieldType.text, isRequired: true),
    ContractField(id: 'price', label: 'السعر', type: ContractFieldType.currency, isRequired: true),
  ],
);
const _fieldValues = {'partyA': 'أحمد', 'partyB': 'سارة', 'price': '500'};

Contract _resultContract(ContractStatus status) => Contract(
  id: 'c1',
  title: _template.title,
  category: _template.category,
  status: status,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  parties: const ['أحمد', 'سارة'],
  fieldValues: _fieldValues,
  templateId: _template.id,
  generatedContent: 'content',
);

Future<ProviderContainer> _pump(WidgetTester tester, {required MockContractsRepository repository}) async {
  // A successful save/generate also refreshes the contracts list.
  when(() => repository.getContracts()).thenAnswer((_) async => const Result.success(<Contract>[]));

  final container = ProviderContainer(overrides: [signedInOverride, localeControllerProvider.overrideWith(() => FixedLocaleController(const Locale('ar'))), contractsRepositoryProvider.overrideWithValue(repository)]);
  addTearDown(container.dispose);
  container.read(contractDraftControllerProvider.notifier)
    ..selectTemplate(_template)
    ..setFieldValue('partyA', 'أحمد')
    ..setFieldValue('partyB', 'سارة')
    ..setFieldValue('price', '500');

  final router = GoRouter(
    initialLocation: RoutePaths.clientContractsNewPreview,
    routes: [
      GoRoute(path: RoutePaths.clientContractsNewPreview, builder: (context, state) => const ContractPreviewScreen()),
      GoRoute(path: RoutePaths.clientContractDetailsPattern, builder: (context, state) => Scaffold(body: Text('details ${state.pathParameters['id']}'))),
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
    registerFallbackValue(_template);
    registerFallbackValue(const Locale('ar'));
  });

  testWidgets('renders parties and details sections from the filled draft', (tester) async {
    await _pump(tester, repository: MockContractsRepository());

    expect(find.text('أحمد'), findsOneWidget);
    expect(find.text('سارة'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
  });

  testWidgets('save as draft persists via the repository and navigates to details', (tester) async {
    final repository = MockContractsRepository();
    when(
      () => repository.saveDraft(template: _template, fieldValues: _fieldValues, locale: any(named: 'locale')),
    ).thenAnswer((_) async => Result.success(_resultContract(ContractStatus.draft)));

    await _pump(tester, repository: repository);
    await tester.tap(find.text('حفظ كمسودة'));
    await tester.pumpAndSettle();

    verify(() => repository.saveDraft(template: _template, fieldValues: _fieldValues, locale: any(named: 'locale'))).called(1);
    expect(find.text('details c1'), findsOneWidget);
  });

  testWidgets('generate shows the success state with a link to the new contract', (tester) async {
    final repository = MockContractsRepository();
    when(
      () => repository.generateContract(template: _template, fieldValues: _fieldValues, locale: any(named: 'locale')),
    ).thenAnswer((_) async => Result.success(_resultContract(ContractStatus.pendingSignature)));

    await _pump(tester, repository: repository);
    await tester.tap(find.text('إنشاء العقد'));
    await tester.pumpAndSettle();

    expect(find.text('تم إنشاء العقد بنجاح!'), findsOneWidget);

    await tester.tap(find.text('عرض التفاصيل'));
    await tester.pumpAndSettle();

    expect(find.text('details c1'), findsOneWidget);
  });
}
