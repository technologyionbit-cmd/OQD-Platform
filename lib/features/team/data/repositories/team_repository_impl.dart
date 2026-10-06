import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/team/data/datasources/team_data_source_provider.dart';
import 'package:aqd_ionbit/features/team/data/datasources/team_remote_data_source.dart';
import 'package:aqd_ionbit/features/team/domain/entities/team_member.dart';
import 'package:aqd_ionbit/features/team/domain/entities/team_member_role.dart';
import 'package:aqd_ionbit/features/team/domain/repositories/team_repository.dart';

class TeamRepositoryImpl implements TeamRepository {
  TeamRepositoryImpl({required TeamRemoteDataSource remoteDataSource, ApiErrorMapper errorMapper = const ApiErrorMapper()})
    : _remote = remoteDataSource,
      _errorMapper = errorMapper;

  final TeamRemoteDataSource _remote;
  final ApiErrorMapper _errorMapper;

  @override
  Future<Result<List<TeamMember>>> getMembers() => _errorMapper.capture(_remote.getMembers);

  @override
  Future<Result<TeamMember>> addMember({required String fullName, required String email, required TeamMemberRole role}) {
    return _errorMapper.capture(() => _remote.addMember(fullName: fullName, email: email, role: role));
  }

  @override
  Future<Result<TeamMember>> updateMemberRole({required String id, required TeamMemberRole role}) {
    return _errorMapper.capture(() => _remote.updateMemberRole(id: id, role: role));
  }

  @override
  Future<Result<void>> removeMember(String id) => _errorMapper.capture(() => _remote.removeMember(id));
}

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepositoryImpl(remoteDataSource: ref.watch(teamRemoteDataSourceProvider));
});
