import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/team/domain/entities/team_member_role.dart';

part 'team_member.freezed.dart';

@freezed
abstract class TeamMember with _$TeamMember {
  const factory TeamMember({
    required String id,
    required String fullName,
    required String email,
    required TeamMemberRole role,
    required DateTime joinedAt,
  }) = _TeamMember;
}
