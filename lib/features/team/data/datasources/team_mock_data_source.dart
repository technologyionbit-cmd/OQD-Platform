import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/features/team/data/datasources/team_remote_data_source.dart';
import 'package:aqd_ionbit/features/team/domain/entities/team_member.dart';
import 'package:aqd_ionbit/features/team/domain/entities/team_member_role.dart';

/// Temporary, isolated stand-in for the real backend — no
/// organization/team-management API is available yet.
class TeamMockDataSource implements TeamRemoteDataSource {
  final List<TeamMember> _members = [
    TeamMember(
      id: 'tm_seed_1',
      fullName: 'شركة الرواد القانونية',
      email: 'company@aqd.test',
      role: TeamMemberRole.admin,
      joinedAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
    TeamMember(
      id: 'tm_seed_2',
      fullName: 'ليلى الزهراني',
      email: 'layla.z@aqd.test',
      role: TeamMemberRole.manager,
      joinedAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    TeamMember(
      id: 'tm_seed_3',
      fullName: 'يوسف الغامدي',
      email: 'yousef.g@aqd.test',
      role: TeamMemberRole.member,
      joinedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  @override
  Future<List<TeamMember>> getMembers() async {
    await _simulateLatency();
    final sorted = List<TeamMember>.of(_members)..sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
    return sorted;
  }

  @override
  Future<TeamMember> addMember({required String fullName, required String email, required TeamMemberRole role}) async {
    await _simulateLatency();
    final member = TeamMember(
      id: 'tm_${DateTime.now().microsecondsSinceEpoch}',
      fullName: fullName,
      email: email,
      role: role,
      joinedAt: DateTime.now(),
    );
    _members.add(member);
    return member;
  }

  @override
  Future<TeamMember> updateMemberRole({required String id, required TeamMemberRole role}) async {
    await _simulateLatency();
    final index = _members.indexWhere((m) => m.id == id);
    if (index == -1) throw const NotFoundFailure();
    final updated = _members[index].copyWith(role: role);
    _members[index] = updated;
    return updated;
  }

  @override
  Future<void> removeMember(String id) async {
    await _simulateLatency();
    _members.removeWhere((m) => m.id == id);
  }

  Future<void> _simulateLatency() => Future.delayed(const Duration(milliseconds: 400));
}
