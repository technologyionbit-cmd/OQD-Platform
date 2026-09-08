import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_mock_data_source.dart';

void main() {
  late LawyersMockDataSource dataSource;

  setUp(() => dataSource = LawyersMockDataSource());

  test('getLawyers returns the seeded lawyers sorted by rating descending', () async {
    final lawyers = await dataSource.getLawyers();

    expect(lawyers.length, 5);
    for (var i = 1; i < lawyers.length; i++) {
      expect(lawyers[i - 1].rating, greaterThanOrEqualTo(lawyers[i].rating));
    }
  });

  test('getLawyerById returns the matching profile', () async {
    final lawyer = await dataSource.getLawyerById('lwr_seed_1');

    expect(lawyer.fullName, 'سارة المطيري');
  });

  test('getLawyerById throws NotFoundFailure for an unknown id', () async {
    expect(dataSource.getLawyerById('nope'), throwsA(isA<NotFoundFailure>()));
  });

  test('updateProfile persists changes for the matching lawyer', () async {
    final lawyer = await dataSource.getLawyerById('lwr_seed_1');
    final updated = await dataSource.updateProfile(lawyer.copyWith(yearsOfExperience: 20));

    expect(updated.yearsOfExperience, 20);
    final reloaded = await dataSource.getLawyerById('lwr_seed_1');
    expect(reloaded.yearsOfExperience, 20);
  });
}
