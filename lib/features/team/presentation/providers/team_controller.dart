import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/current_user_id_provider.dart';
import 'package:aqd_ionbit/features/team/data/repositories/team_repository_impl.dart';
import 'package:aqd_ionbit/features/team/domain/entities/team_member.dart';
import 'package:aqd_ionbit/features/team/domain/entities/team_member_role.dart';
import 'package:aqd_ionbit/features/team/domain/repositories/team_repository.dart';

class TeamController extends AsyncNotifier<List<TeamMember>> {
  TeamRepository get _repository => ref.read(teamRepositoryProvider);

  @override
  FutureOr<List<TeamMember>> build() async {
    ref.watch(teamRepositoryProvider);
    if (ref.watch(currentUserIdProvider) == null) return const []; // Signed out: no one's data.
    final result = await _repository.getMembers();
    return result.fold((failure) => throw failure, (members) => members);
  }

  Future<void> refresh() async {
    final result = await _repository.getMembers();
    state = result.fold((failure) => AsyncError(failure, StackTrace.current), AsyncData.new);
  }

  Future<Result<TeamMember>> addMember({required String fullName, required String email, required TeamMemberRole role}) async {
    final result = await _repository.addMember(fullName: fullName, email: email, role: role);
    if (result.isSuccess) await refresh();
    return result;
  }

  Future<Result<TeamMember>> updateMemberRole({required String id, required TeamMemberRole role}) async {
    final result = await _repository.updateMemberRole(id: id, role: role);
    if (result.isSuccess) await refresh();
    return result;
  }

  Future<Result<void>> removeMember(String id) async {
    final result = await _repository.removeMember(id);
    if (result.isSuccess) await refresh();
    return result;
  }
}

final teamControllerProvider = AsyncNotifierProvider<TeamController, List<TeamMember>>(TeamController.new);

final teamMemberByIdProvider = Provider.autoDispose.family<TeamMember?, String>(
  (ref, id) => ref.watch(teamControllerProvider).value?.where((m) => m.id == id).firstOrNull,
);
