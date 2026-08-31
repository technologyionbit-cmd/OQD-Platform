import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';

/// Contract the presentation layer programs against. The implementation
/// (`AuthRepositoryImpl`) is backed by a mock data source until the real
/// backend contract is available — nothing above this interface knows or
/// cares which.
abstract interface class AuthRepository {
  Future<Result<({AuthUser user, AuthTokens tokens})>> login({required String email, required String password});

  Future<Result<({AuthUser user, AuthTokens tokens})>> register(RegisterRequest request);

  Future<Result<AuthTokens>> refreshToken(String refreshToken);

  Future<Result<AuthUser>> currentUser();

  Future<void> logout();

  Future<Result<void>> requestOtp({required String destination});

  Future<Result<bool>> verifyOtp({required String destination, required String code});

  Future<Result<void>> resetPassword({required String destination, required String code, required String newPassword});
}
