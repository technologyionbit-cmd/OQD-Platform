import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_theme.dart';
import 'package:aqd_ionbit/features/contracts/data/repositories/contracts_repository_impl.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_category.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_status.dart';
import 'package:aqd_ionbit/features/contracts/domain/repositories/contracts_repository.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contract_details_screen.dart';

class MockContractsRepository extends Mock implements ContractsRepository {}

Contract _contract(ContractStatus status) => Contract(
  id: 'c1',
  title: 'عقد بيع',
  category: ContractCategory.sale,
  status: status,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026, 1, 2),
  parties: const ['أحمد', 'سارة'],
  fieldValues: const {'partyA': 'أحمد'},
  templateId: 'sale',
  generatedContent: 'نص العقد الكامل هنا',
);

Future<ProviderContainer> _pump(WidgetTester tester, {required MockContractsRepository repository}) async {
  final container = ProviderContainer(overrides: [contractsRepositoryProvider.overrideWithValue(repository)]);
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: RoutePaths.clientContractDetails('c1'),
    routes: [
      GoRoute(
        path: RoutePaths.clientContractDetailsPattern,
        builder: (context, state) => ContractDetailsScreen(contractId: state.pathParameters['id']!),
      ),
      GoRoute(path: RoutePaths.clientContractsNewForm, builder: (context, state) => const Scaffold(body: Text('form'))),
      GoRoute(path: RoutePaths.clientContracts, builder: (context, state) => const Scaffold(body: Text('list'))),
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
  testWidgets('renders contract data and content', (tester) async {
    final repository = MockContractsRepository();
    when(() => repository.getContractById('c1')).thenAnswer((_) async => Result.success(_contract(ContractStatus.completed)));

    await _pump(tester, repository: repository);

    expect(find.text('عقد بيع'), findsWidgets);
    expect(find.text('نص العقد الكامل هنا'), findsOneWidget);
    expect(find.text('أحمد — سارة'), findsOneWidget);
  });

  testWidgets('a completed contract has no edit/delete actions', (tester) async {
    final repository = MockContractsRepository();
    when(() => repository.getContractById('c1')).thenAnswer((_) async => Result.success(_contract(ContractStatus.completed)));

    await _pump(tester, repository: repository);

    expect(find.text('تعديل'), findsNothing);
    expect(find.text('حذف'), findsNothing);
  });

  testWidgets('a draft contract can be deleted after confirmation', (tester) async {
    final repository = MockContractsRepository();
    when(() => repository.getContractById('c1')).thenAnswer((_) async => Result.success(_contract(ContractStatus.draft)));
    when(repository.getContracts).thenAnswer((_) async => const Result.success(<Contract>[]));
    when(() => repository.deleteContract('c1')).thenAnswer((_) async => const Result.success(null));

    // Taller than the default 800x600 test surface — the details screen's
    // content (title, detail card, full contract text, three action
    // buttons) genuinely doesn't fit the default height, and scrolling the
    // delete button precisely into view is fussier than just giving the
    // test enough room.
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pump(tester, repository: repository);
    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle();

    // Confirmation dialog stands between the tap and an actual delete.
    expect(find.byType(AlertDialog), findsOneWidget);
    verifyNever(() => repository.deleteContract('c1'));

    await tester.tap(find.text('حذف').last);
    await tester.pumpAndSettle();

    verify(() => repository.deleteContract('c1')).called(1);
    expect(find.text('list'), findsOneWidget);
  });

  testWidgets('shows an error view when the contract fails to load', (tester) async {
    final repository = MockContractsRepository();
    when(() => repository.getContractById('c1')).thenAnswer((_) async => const Result.failure(NotFoundFailure()));

    await _pump(tester, repository: repository);

    expect(find.text('عقد بيع'), findsNothing);
    expect(find.text('إعادة المحاولة'), findsOneWidget); // the ErrorView's retry button
  });
}
