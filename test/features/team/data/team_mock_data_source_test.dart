import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/features/team/data/datasources/team_mock_data_source.dart';
import 'package:aqd_ionbit/features/team/domain/entities/team_member_role.dart';

void main() {
  late TeamMockDataSource dataSource;

  setUp(() => dataSource = TeamMockDataSource());

  test('getMembers returns the seeded team members', () async {
    final members = await dataSource.getMembers();
    expect(members.length, 3);
  });

  test('addMember appends a new member', () async {
    final before = await dataSource.getMembers();
    final added = await dataSource.addMember(fullName: 'عضو جديد', email: 'new@aqd.test', role: TeamMemberRole.member);

    expect(added.role, TeamMemberRole.member);
    final after = await dataSource.getMembers();
    expect(after.length, before.length + 1);
  });

  test('updateMemberRole changes only the targeted member', () async {
    final updated = await dataSource.updateMemberRole(id: 'tm_seed_3', role: TeamMemberRole.manager);
    expect(updated.role, TeamMemberRole.manager);
  });

  test('removeMember deletes the member from the roster', () async {
    final before = await dataSource.getMembers();
    await dataSource.removeMember('tm_seed_3');
    final after = await dataSource.getMembers();

    expect(after.length, before.length - 1);
    expect(after.any((m) => m.id == 'tm_seed_3'), isFalse);
  });
}
