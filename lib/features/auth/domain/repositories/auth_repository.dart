import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_session.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';

/// Contract the presentation layer programs against. Implemented by
/// `AuthRepositoryImpl`, which is backed by the real NestJS auth API.
abstract interface class AuthRepository {
  Future<Result<({AuthUser user, AuthTokens tokens})>> login({required String email, required String password});

  Future<Result<({AuthUser user, AuthTokens tokens})>> register(RegisterRequest request);

  Future<Result<AuthTokens>> refreshToken(String refreshToken);

  Future<Result<AuthUser>> currentUser();

  Future<Result<AuthUser>> updateProfile({required String fullName, required String email});

  Future<void> logout();

  Future<Result<void>> requestOtp({required String destination});

  Future<Result<bool>> verifyOtp({required String destination, required String code});

  Future<Result<void>> resetPassword({required String destination, required String code, required String newPassword});

  Future<Result<void>> changePassword({required String currentPassword, required String newPassword});

  Future<Result<List<AuthSession>>> listSessions();

  Future<Result<void>> revokeSession(String sessionId);

  Future<Result<void>> revokeOtherSessions();
}
