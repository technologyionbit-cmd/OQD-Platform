import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_theme.dart';
import 'package:aqd_ionbit/features/documents/data/repositories/documents_repository_impl.dart';
import 'package:aqd_ionbit/features/documents/domain/entities/document.dart';
import 'package:aqd_ionbit/features/documents/domain/entities/document_source_type.dart';
import 'package:aqd_ionbit/features/documents/domain/repositories/documents_repository.dart';
import 'package:aqd_ionbit/features/documents/presentation/screens/documents_screen.dart';

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

Document _document(String id, String title, {String? contractId}) {
  return Document(
    id: id,
    title: title,
    sourceType: contractId != null ? DocumentSourceType.generatedContract : DocumentSourceType.uploaded,
    createdAt: DateTime(2026, 1, 1),
    sizeLabel: '200 KB',
    contractId: contractId,
  );
}

Future<void> _pump(WidgetTester tester, MockDocumentsRepository repository) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [documentsRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const DocumentsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late MockDocumentsRepository repository;

  setUp(() => repository = MockDocumentsRepository());

  testWidgets('renders the seeded documents', (tester) async {
    when(
      () => repository.getDocuments(),
    ).thenAnswer((_) async => Result.success([_document('1', 'عقد خدمات', contractId: 'c1'), _document('2', 'ملف مرفوع')]));

    await _pump(tester, repository);

    expect(find.text('عقد خدمات'), findsOneWidget);
    expect(find.text('ملف مرفوع'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no documents', (tester) async {
    when(() => repository.getDocuments()).thenAnswer((_) async => const Result.success(<Document>[]));

    await _pump(tester, repository);

    expect(find.text('لا توجد مستندات بعد'), findsOneWidget);
  });

  testWidgets('search narrows the visible documents by title', (tester) async {
    when(
      () => repository.getDocuments(),
    ).thenAnswer((_) async => Result.success([_document('1', 'عقد خدمات', contractId: 'c1'), _document('2', 'عقد إيجار', contractId: 'c2')]));

    await _pump(tester, repository);
    await tester.enterText(find.byType(TextField), 'إيجار');
    await tester.pumpAndSettle();

    expect(find.text('عقد إيجار'), findsOneWidget);
    expect(find.text('عقد خدمات'), findsNothing);
  });
}
