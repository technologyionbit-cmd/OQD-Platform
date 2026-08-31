import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';

/// Contract the presentation layer programs against. The implementation
/// (`AuthRepositoryImpl`) is backed by a mock data source until the real
/// backend contract is available — nothing above this interface knows or
/// cares which.
abstract interface class AuthRepository {
  Future<Result<({AuthUser user, AuthTokens tokens})>> login({required String email, required String password});

  Future<Result<AuthTokens>> refreshToken(String refreshToken);

  Future<Result<AuthUser>> currentUser();

  Future<void> logout();

  // Registration/OTP/password-recovery are part of the auth contract this
  // interface exists to describe, but their screens aren't built in the
  // foundation phase — declared here so the repository/mock boundary is
  // complete and the next phase only adds use cases + UI, not new contracts.
  Future<Result<void>> requestPasswordReset({required String email});

  Future<Result<void>> requestOtp({required String destination});

  Future<Result<bool>> verifyOtp({required String destination, required String code});
}
