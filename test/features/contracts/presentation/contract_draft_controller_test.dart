import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/features/contracts/data/repositories/contracts_repository_impl.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_category.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field_type.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_status.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_template.dart';
import 'package:aqd_ionbit/features/contracts/domain/repositories/contracts_repository.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contract_draft_controller.dart';
import 'package:aqd_ionbit/features/documents/data/repositories/documents_repository_impl.dart';
import 'package:aqd_ionbit/features/documents/domain/entities/document.dart';
import 'package:aqd_ionbit/features/documents/domain/entities/document_source_type.dart';
import 'package:aqd_ionbit/features/documents/domain/repositories/documents_repository.dart';

class MockContractsRepository extends Mock implements ContractsRepository {}

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

const _template = ContractTemplate(
  id: 't1',
  category: ContractCategory.other,
  title: 'Test Template',
  fields: [
    ContractField(id: 'partyA', label: 'Party A', type: ContractFieldType.text, isRequired: true),
    ContractField(id: 'email', label: 'Email', type: ContractFieldType.email, isRequired: false),
    ContractField(id: 'amount', label: 'Amount', type: ContractFieldType.number, isRequired: true),
    ContractField(id: 'startDate', label: 'Start Date', type: ContractFieldType.date, isRequired: true),
  ],
);

void main() {
  late ProviderContainer container;
  late MockContractsRepository repository;
  late MockDocumentsRepository documentsRepository;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  setUp(() {
    repository = MockContractsRepository();
    documentsRepository = MockDocumentsRepository();
    container = ProviderContainer(
      overrides: [
        contractsRepositoryProvider.overrideWithValue(repository),
        documentsRepositoryProvider.overrideWithValue(documentsRepository),
      ],
    );
    addTearDown(container.dispose);
  });

  ContractDraftController controller() => container.read(contractDraftControllerProvider.notifier);

  test('validate() fails when no template is selected', () {
    expect(controller().validate(l10n), isFalse);
  });

  test('validate() reports required fields left empty', () {
    controller().selectTemplate(_template);

    final isValid = controller().validate(l10n);

    expect(isValid, isFalse);
    final errors = container.read(contractDraftControllerProvider).errors;
    expect(errors['partyA'], l10n.validationRequired);
    expect(errors['amount'], l10n.validationRequired);
    expect(errors['startDate'], l10n.validationRequired);
    expect(errors.containsKey('email'), isFalse, reason: 'optional + empty should not error');
  });

  test('validate() checks type-appropriate format for filled fields', () {
    controller()
      ..selectTemplate(_template)
      ..setFieldValue('partyA', 'Acme')
      ..setFieldValue('email', 'not-an-email')
      ..setFieldValue('amount', 'not-a-number')
      ..setFieldValue('startDate', 'not-a-date');

    final isValid = controller().validate(l10n);

    expect(isValid, isFalse);
    final errors = container.read(contractDraftControllerProvider).errors;
    expect(errors['email'], l10n.validationInvalidEmail);
    expect(errors['amount'], l10n.validationInvalidNumber);
    expect(errors['startDate'], l10n.validationInvalidDate);
  });

  test('validate() passes once every required field is filled with a valid value', () {
    controller()
      ..selectTemplate(_template)
      ..setFieldValue('partyA', 'Acme')
      ..setFieldValue('amount', '1200')
      ..setFieldValue('startDate', DateTime(2026, 1, 1).toIso8601String());

    expect(controller().validate(l10n), isTrue);
    expect(container.read(contractDraftControllerProvider).errors, isEmpty);
  });

  group('saveDraft / generate', () {
    final tokens = Contract(
      id: 'c1',
      title: _template.title,
      category: _template.category,
      status: ContractStatus.draft,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      parties: const ['Acme'],
      fieldValues: const {'partyA': 'Acme'},
      templateId: _template.id,
      generatedContent: 'content',
    );

    setUp(() {
      when(() => repository.getContracts()).thenAnswer((_) async => const Result.success(<Contract>[]));
    });

    test('saveDraft persists via the repository and resets the draft on success', () async {
      controller()
        ..selectTemplate(_template)
        ..setFieldValue('partyA', 'Acme');
      when(
        () => repository.saveDraft(template: _template, fieldValues: {'partyA': 'Acme'}, contractId: null),
      ).thenAnswer((_) async => Result.success(tokens));

      final result = await controller().saveDraft();

      expect(result.isSuccess, isTrue);
      expect(container.read(contractDraftControllerProvider).template, isNull, reason: 'draft resets after a successful save');
    });

    test('a failed save leaves the draft state untouched so the user can retry', () async {
      controller()
        ..selectTemplate(_template)
        ..setFieldValue('partyA', 'Acme');
      when(
        () => repository.saveDraft(template: _template, fieldValues: {'partyA': 'Acme'}, contractId: null),
      ).thenAnswer((_) async => const Result.failure(ServerFailure()));

      final result = await controller().saveDraft();

      expect(result.isFailure, isTrue);
      expect(container.read(contractDraftControllerProvider).template, _template);
    });

    test('a successful generate() also adds the contract to the documents vault', () async {
      controller()
        ..selectTemplate(_template)
        ..setFieldValue('partyA', 'Acme');
      when(
        () => repository.generateContract(template: _template, fieldValues: {'partyA': 'Acme'}, contractId: null),
      ).thenAnswer((_) async => Result.success(tokens));
      when(
        () => documentsRepository.addGeneratedContractDocument(contractId: tokens.id, title: tokens.title),
      ).thenAnswer(
        (_) async => Result.success(
          Document(
            id: 'd1',
            title: tokens.title,
            sourceType: DocumentSourceType.generatedContract,
            createdAt: DateTime(2026, 1, 1),
            sizeLabel: '200 KB',
            contractId: tokens.id,
          ),
        ),
      );
      when(() => documentsRepository.getDocuments()).thenAnswer((_) async => const Result.success(<Document>[]));

      final result = await controller().generate();

      expect(result.isSuccess, isTrue);
      verify(() => documentsRepository.addGeneratedContractDocument(contractId: tokens.id, title: tokens.title)).called(1);
    });
  });
}
