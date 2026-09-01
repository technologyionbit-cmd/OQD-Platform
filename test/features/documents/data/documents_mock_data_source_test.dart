import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/features/documents/data/datasources/documents_mock_data_source.dart';
import 'package:aqd_ionbit/features/documents/domain/entities/document_source_type.dart';

void main() {
  late DocumentsMockDataSource dataSource;

  setUp(() => dataSource = DocumentsMockDataSource());

  test('getDocuments returns the seeded document sorted by most-recent first', () async {
    final documents = await dataSource.getDocuments();

    expect(documents.length, 1);
    expect(documents.first.id, 'd_seed_1');
    expect(documents.first.contractId, 'c_seed_1');
  });

  test('addGeneratedContractDocument inserts a new document linked to the contract', () async {
    final before = await dataSource.getDocuments();

    final added = await dataSource.addGeneratedContractDocument(contractId: 'c_new', title: 'عقد جديد');

    expect(added.contractId, 'c_new');
    expect(added.title, 'عقد جديد');
    expect(added.sourceType, DocumentSourceType.generatedContract);

    final after = await dataSource.getDocuments();
    expect(after.length, before.length + 1);
    expect(after.first.id, added.id);
  });
}
