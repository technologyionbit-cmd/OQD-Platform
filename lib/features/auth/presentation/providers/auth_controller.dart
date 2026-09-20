import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';
import 'package:aqd_ionbit/features/auth/domain/repositories/auth_repository.dart';

/// App-wide session state: `AsyncLoading` while resolving the stored
/// session on startup, `AsyncData(null)` when unauthenticated,
/// `AsyncData(user)` when authenticated. The router's redirect logic and
/// every role-gated screen watch this — it is the single source of truth
/// for "is someone signed in", independent of any one screen's lifecycle.
///
/// A failed login is deliberately NOT surfaced as `AsyncError` here — that
/// would incorrectly put the whole app into a global error state over what
/// is really a form-level concern. [login] returns a [Result] so the
/// calling screen shows the failure inline instead.
class AuthController extends AsyncNotifier<AuthUser?> {
  late final AuthRepository _repository;

  @override
  FutureOr<AuthUser?> build() async {
    _repository = ref.watch(authRepositoryProvider);

    ref.read(tokenRefresherProvider).register(() async {
      final refreshToken = ref.read(tokenManagerProvider).current?.refreshToken;
      if (refreshToken == null) return null;
      final result = await _repository.refreshToken(refreshToken);
      return result.valueOrNull;
    });
    ref.read(sessionExpiredNotifierProvider).registerHandler(_handleSessionExpired);

    final storedTokens = await ref.read(tokenManagerProvider).loadFromStorage();
    if (storedTokens == null) return null;

    final result = await _repository.currentUser();
    return result.valueOrNull;
  }

  Future<Result<AuthUser>> login({required String email, required String password}) async {
    final result = await _repository.login(email: email, password: password);
    return result.fold(
      Result.failure,
      (data) {
        state = AsyncData(data.user);
        return Result.success(data.user);
      },
    );
  }

  Future<Result<AuthUser>> register(RegisterRequest request) async {
    final result = await _repository.register(request);
    return result.fold(
      Result.failure,
      (data) {
        state = AsyncData(data.user);
        return Result.success(data.user);
      },
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncData(null);
  }

  Future<Result<AuthUser>> updateProfile({required String fullName, required String email}) async {
    final result = await _repository.updateProfile(fullName: fullName, email: email);
    result.fold((failure) {}, (user) => state = AsyncData(user));
    return result;
  }

  void _handleSessionExpired() {
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthUser?>(AuthController.new);
