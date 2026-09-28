import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';
import 'package:aqd_ionbit/features/auth/domain/repositories/auth_repository.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/email_verification_prompt.dart';

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
///
/// When the stored session can't be verified because the server is
/// unreachable, the state becomes `AsyncError` carrying the [Failure]: the
/// router keeps the splash screen up and offers a retry, instead of
/// pretending the user is signed out. Retrying is `ref.invalidate` on this
/// provider.
class AuthController extends AsyncNotifier<AuthUser?> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  FutureOr<AuthUser?> build() async {
    ref.watch(authRepositoryProvider);
    ref.read(tokenRefresherProvider).register(_repository.refreshSession);
    ref.read(sessionExpiredNotifierProvider).registerHandler(_handleSessionExpired);

    final result = await _repository.restoreSession();
    return switch (result) {
      Success(:final data) => data,
      ResultFailure(:final failure) => throw failure,
    };
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
        // Set before the user so the router's first look at the new
        // session already routes to the code screen.
        if (!data.user.emailVerified) ref.read(emailVerificationPromptProvider.notifier).show();
        state = AsyncData(data.user);
        return Result.success(data.user);
      },
    );
  }

  /// On success the router leaves the verify screen by itself, because
  /// the user it reads is now verified.
  Future<Result<AuthUser>> verifyEmail(String code) async {
    final result = await _repository.verifyEmail(code: code);
    result.fold((failure) {}, (user) {
      ref.read(emailVerificationPromptProvider.notifier).dismiss();
      state = AsyncData(user);
    });
    return result;
  }

  Future<Result<void>> resendEmailVerification() => _repository.resendEmailVerification();

  Future<void> logout() async {
    await _repository.logout();
    ref.read(emailVerificationPromptProvider.notifier).dismiss();
    state = const AsyncData(null);
  }

  Future<Result<AuthUser>> updateProfile({required String fullName, required String email}) async {
    final result = await _repository.updateProfile(fullName: fullName, email: email);
    result.fold((failure) {}, (user) => state = AsyncData(user));
    return result;
  }

  /// Called by AuthInterceptor once the server has refused the refresh
  /// token — the session is over, so the stored tokens go too.
  Future<void> _handleSessionExpired() async {
    await _repository.clearLocalSession();
    ref.read(emailVerificationPromptProvider.notifier).dismiss();
    state = const AsyncData(null);
  }
}

/// Automatic retry is off: a failed session restore waits on the splash
/// screen for the user to retry, instead of silently looping in the
/// background while the UI shows a spinner.
final authControllerProvider = AsyncNotifierProvider<AuthController, AuthUser?>(AuthController.new, retry: (_, _) => null);
