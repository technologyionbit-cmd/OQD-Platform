import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_session.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';

/// Wire-level contract for the auth feature — one method per backend
/// endpoint (`/v1/auth/*`). Authenticated calls need no token argument:
/// the shared `AuthInterceptor` attaches the access token from
/// [TokenManager] to every request automatically.
///
/// Every method throws a [Failure] (see `core/errors`) on any failure
/// path — never a raw [DioException] — so [AuthRepositoryImpl] maps errors
/// uniformly.
abstract interface class AuthRemoteDataSource {
  Future<({AuthUser user, AuthTokens tokens})> login({required String email, required String password});

  Future<({AuthUser user, AuthTokens tokens})> register(RegisterRequest request);

  /// Public endpoint — sends [refreshToken] in the body, no access header.
  Future<AuthTokens> refreshToken(String refreshToken);

  Future<AuthUser> currentUser();

  Future<AuthUser> updateProfile({required String fullName, required String email});

  Future<void> logout(String refreshToken);

  /// Confirms the signed-in user's email with the emailed [code] and
  /// returns the updated user.
  Future<AuthUser> verifyEmail({required String code});

  /// Asks the server to email a new verification code.
  Future<void> resendEmailVerification();

  Future<void> requestPasswordReset({required String email});

  Future<void> verifyPasswordResetCode({required String email, required String code});

  Future<void> resetPassword({required String email, required String code, required String newPassword});

  Future<void> changePassword({required String currentPassword, required String newPassword});

  Future<List<AuthSession>> listSessions();

  Future<void> revokeSession(String sessionId);

  Future<void> revokeOtherSessions();
}
