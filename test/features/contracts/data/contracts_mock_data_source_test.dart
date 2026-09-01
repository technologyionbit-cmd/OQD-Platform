import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/features/contracts/data/datasources/contracts_mock_data_source.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_status.dart';

void main() {
  late ContractsMockDataSource dataSource;

  setUp(() => dataSource = ContractsMockDataSource());

  group('getTemplates', () {
    test('returns the same 7 categories with matching ids for both locales', () async {
      final arTemplates = await dataSource.getTemplates(const Locale('ar'));
      final enTemplates = await dataSource.getTemplates(const Locale('en'));

      expect(arTemplates.length, 7);
      expect(enTemplates.map((t) => t.id).toSet(), arTemplates.map((t) => t.id).toSet());
    });

    test('template content is actually translated, not just re-tagged', () async {
      final arTemplates = await dataSource.getTemplates(const Locale('ar'));
      final enTemplates = await dataSource.getTemplates(const Locale('en'));

      final arEmployment = arTemplates.firstWhere((t) => t.id == 'employment');
      final enEmployment = enTemplates.firstWhere((t) => t.id == 'employment');

      expect(arEmployment.title, isNot(enEmployment.title));
      expect(arEmployment.fields.length, enEmployment.fields.length);
    });
  });

  test('getContracts returns the seeded contracts sorted by most-recently-updated', () async {
    final contracts = await dataSource.getContracts();

    expect(contracts.length, 2);
    expect(contracts.first.updatedAt.isAfter(contracts.last.updatedAt), isTrue);
  });

  test('getContractById throws NotFoundFailure for an unknown id', () {
    expect(() => dataSource.getContractById('nope'), throwsA(isA<NotFoundFailure>()));
  });

  group('saveDraft / generateContract', () {
    Future<dynamic> firstTemplate() async => (await dataSource.getTemplates(const Locale('ar'))).first;

    test('saveDraft creates a new contract with draft status', () async {
      final template = await firstTemplate();
      final before = await dataSource.getContracts();

      final saved = await dataSource.saveDraft(template: template, fieldValues: {'partyA': 'أحمد', 'partyB': 'شركة الأفق'});

      expect(saved.status, ContractStatus.draft);
      expect(saved.parties, ['أحمد', 'شركة الأفق']);
      final after = await dataSource.getContracts();
      expect(after.length, before.length + 1);
    });

    test('generateContract creates a new contract with pending-signature status', () async {
      final template = await firstTemplate();

      final generated = await dataSource.generateContract(template: template, fieldValues: {'partyA': 'a', 'partyB': 'b'});

      expect(generated.status, ContractStatus.pendingSignature);
      expect(generated.generatedContent, contains(template.title));
    });

    test('passing an existing contractId updates in place instead of creating a new one', () async {
      final template = await firstTemplate();
      final draft = await dataSource.saveDraft(template: template, fieldValues: {'partyA': 'a', 'partyB': 'b'});
      final before = await dataSource.getContracts();

      final updated = await dataSource.generateContract(
        template: template,
        fieldValues: {'partyA': 'a2', 'partyB': 'b2'},
        contractId: draft.id,
      );

      expect(updated.id, draft.id);
      expect(updated.status, ContractStatus.pendingSignature);
      final after = await dataSource.getContracts();
      expect(after.length, before.length);
    });

    test('updating an unknown contractId throws NotFoundFailure', () async {
      final template = await firstTemplate();
      expect(
        () => dataSource.saveDraft(template: template, fieldValues: const {}, contractId: 'missing'),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  test('deleteContract removes the contract from the list', () async {
    final contracts = await dataSource.getContracts();
    final idToDelete = contracts.first.id;

    await dataSource.deleteContract(idToDelete);

    final after = await dataSource.getContracts();
    expect(after.any((c) => c.id == idToDelete), isFalse);
  });
}
