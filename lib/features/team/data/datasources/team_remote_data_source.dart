import 'package:aqd_ionbit/features/team/domain/entities/team_member.dart';
import 'package:aqd_ionbit/features/team/domain/entities/team_member_role.dart';

/// Wire-level contract for the company team feature. Mirrors
/// `ContractsRemoteDataSource` — throws a [Failure] on any failure path,
/// never a raw exception.
abstract interface class TeamRemoteDataSource {
  Future<List<TeamMember>> getMembers();

  Future<TeamMember> addMember({required String fullName, required String email, required TeamMemberRole role});

  Future<TeamMember> updateMemberRole({required String id, required TeamMemberRole role});

  Future<void> removeMember(String id);
}
