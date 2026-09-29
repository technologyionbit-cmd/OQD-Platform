import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_session.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/current_user_id_provider.dart';

/// Loads the signed-in user's active sessions and revokes them, refreshing
/// the list after each change. Backed by the real `/auth/sessions` API.
class ActiveSessionsController extends AsyncNotifier<List<AuthSession>> {
  @override
  Future<List<AuthSession>> build() async {
    if (ref.watch(currentUserIdProvider) == null) return const []; // Signed out: no one's data.
    final result = await ref.watch(authRepositoryProvider).listSessions();
    return switch (result) {
      Success(:final data) => data,
      ResultFailure(:final failure) => throw failure,
    };
  }

  Future<Result<void>> revoke(String sessionId) async {
    final result = await ref.read(authRepositoryProvider).revokeSession(sessionId);
    if (result.isSuccess) {
      state = AsyncData(
        (state.value ?? const []).where((session) => session.id != sessionId).toList(growable: false),
      );
    }
    return result;
  }

  Future<Result<void>> revokeOthers() async {
    final result = await ref.read(authRepositoryProvider).revokeOtherSessions();
    if (result.isSuccess) {
      state = AsyncData(
        (state.value ?? const <AuthSession>[]).where((session) => session.isCurrent).toList(growable: false),
      );
    }
    return result;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(authRepositoryProvider).listSessions();
      return switch (result) {
        Success(:final data) => data,
        ResultFailure(:final failure) => throw failure,
      };
    });
  }
}

final activeSessionsControllerProvider =
    AsyncNotifierProvider<ActiveSessionsController, List<AuthSession>>(ActiveSessionsController.new);
