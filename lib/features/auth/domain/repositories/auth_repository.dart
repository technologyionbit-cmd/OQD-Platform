import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/network/auth_session_ports.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_session.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';

/// Contract the presentation layer programs against. Implemented by
/// `AuthRepositoryImpl`, which is backed by the real NestJS auth API.
abstract interface class AuthRepository {
  Future<Result<({AuthUser user, AuthTokens tokens})>> login({required String email, required String password});

  Future<Result<({AuthUser user, AuthTokens tokens})>> register(RegisterRequest request);

  /// Resolves the session persisted by a previous launch: `null` when there
  /// is none or the server no longer accepts it (the stale tokens are then
  /// cleared), the user when it is still valid, and a [Failure] when the
  /// server could not be reached to find out — the tokens are kept then.
  Future<Result<AuthUser?>> restoreSession();

  /// Exchanges the stored refresh token for a new pair and persists it.
  Future<RefreshOutcome> refreshSession();

  /// Drops the local tokens without contacting the server — for when the
  /// server has already ended the session.
  Future<void> clearLocalSession();

  Future<Result<AuthUser>> currentUser();

  Future<Result<AuthUser>> updateProfile({required String fullName, required String email});

  Future<void> logout();

  Future<Result<AuthUser>> verifyEmail({required String code});

  Future<Result<void>> resendEmailVerification();

  Future<Result<void>> requestOtp({required String destination});

  Future<Result<bool>> verifyOtp({required String destination, required String code});

  Future<Result<void>> resetPassword({required String destination, required String code, required String newPassword});

  Future<Result<void>> changePassword({required String currentPassword, required String newPassword});

  Future<Result<List<AuthSession>>> listSessions();

  Future<Result<void>> revokeSession(String sessionId);

  Future<Result<void>> revokeOtherSessions();
}
