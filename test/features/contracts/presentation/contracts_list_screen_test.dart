import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_theme.dart';
import 'package:aqd_ionbit/features/contracts/data/repositories/contracts_repository_impl.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_category.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_status.dart';
import 'package:aqd_ionbit/features/contracts/domain/repositories/contracts_repository.dart';
import 'package:aqd_ionbit/features/contracts/presentation/screens/contracts_list_screen.dart';
import '../../../support/signed_in_override.dart';

class MockContractsRepository extends Mock implements ContractsRepository {}

Contract _contract(String id, String title, ContractStatus status) {
  return Contract(
    id: id,
    title: title,
    category: ContractCategory.serviceAgreement,
    status: status,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    parties: const ['A', 'B'],
    fieldValues: const {},
    templateId: 'service_agreement',
    generatedContent: 'content',
  );
}

Future<void> _pump(WidgetTester tester, MockContractsRepository repository) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [signedInOverride, contractsRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const ContractsListScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late MockContractsRepository repository;

  setUp(() => repository = MockContractsRepository());

  testWidgets('renders the seeded contracts', (tester) async {
    when(() => repository.getContracts()).thenAnswer(
      (_) async => Result.success([_contract('1', 'عقد خدمات', ContractStatus.completed), _contract('2', 'عقد إيجار', ContractStatus.draft)]),
    );

    await _pump(tester, repository);

    expect(find.text('عقد خدمات'), findsOneWidget);
    expect(find.text('عقد إيجار'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no contracts', (tester) async {
    when(() => repository.getContracts()).thenAnswer((_) async => const Result.success(<Contract>[]));

    await _pump(tester, repository);

    expect(find.text('لا توجد عقود بعد'), findsOneWidget);
  });

  testWidgets('search narrows the visible contracts by title', (tester) async {
    when(() => repository.getContracts()).thenAnswer(
      (_) async => Result.success([_contract('1', 'عقد خدمات', ContractStatus.completed), _contract('2', 'عقد إيجار', ContractStatus.draft)]),
    );

    await _pump(tester, repository);
    await tester.enterText(find.byType(TextField), 'إيجار');
    await tester.pumpAndSettle();

    expect(find.text('عقد إيجار'), findsOneWidget);
    expect(find.text('عقد خدمات'), findsNothing);
  });
}
