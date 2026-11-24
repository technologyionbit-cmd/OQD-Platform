import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/features/auth/data/auth_repository_impl.dart';
import 'package:aqd_admin/features/auth/domain/admin_user.dart';
import 'package:aqd_admin/features/auth/domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    dio: ref.watch(apiClientProvider).dio,
    session: ref.watch(sessionStoreProvider),
  ),
);

/// Why the user is on the sign-in screen without having asked to be.
enum SignInNotice { none, sessionExpired }

class SignInNoticeController extends Notifier<SignInNotice> {
  @override
  SignInNotice build() => SignInNotice.none;

  // ignore: use_setters_to_change_properties
  void show(SignInNotice notice) => state = notice;
}

final signInNoticeProvider =
    NotifierProvider<SignInNoticeController, SignInNotice>(SignInNoticeController.new);

/// The single source of truth for "who is signed in".
///
/// `AsyncLoading` while the session is restored from the refresh cookie,
/// `AsyncData(null)` when signed out, `AsyncData(user)` when signed in.
/// If the server cannot be reached while restoring, the state is
/// `AsyncError` and the splash screen offers a retry (`ref.invalidate`).
class AuthController extends AsyncNotifier<AdminUser?> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<AdminUser?> build() async {
    ref.read(apiClientProvider).registerSessionHandlers(
          refresher: _refreshSession,
          onSessionExpired: _handleSessionExpired,
        );
    return _repository.restoreSession();
  }

  /// Throws a `Failure` so the form can show the reason inline; the global
  /// state stays signed-out (a wrong password is not an app-level error).
  Future<void> login({required String phone, required String password}) async {
    final user = await _repository.login(phone: phone, password: password);
    ref.read(signInNoticeProvider.notifier).show(SignInNotice.none);
    state = AsyncData(user);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncData(null);
  }

  Future<bool> _refreshSession() async {
    try {
      return await _repository.restoreSession() != null;
    } on Failure {
      // Transient (network): keep the user in, the original call fails.
      return false;
    }
  }

  void _handleSessionExpired() {
    if (state.value == null) return;
    ref.read(signInNoticeProvider.notifier).show(SignInNotice.sessionExpired);
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AdminUser?>(AuthController.new);
