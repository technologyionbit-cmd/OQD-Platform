import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/team/domain/entities/team_member.dart';
import 'package:aqd_ionbit/features/team/domain/entities/team_member_role.dart';

abstract interface class TeamRepository {
  Future<Result<List<TeamMember>>> getMembers();

  Future<Result<TeamMember>> addMember({required String fullName, required String email, required TeamMemberRole role});

  Future<Result<TeamMember>> updateMemberRole({required String id, required TeamMemberRole role});

  Future<Result<void>> removeMember(String id);
}
