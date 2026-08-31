import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';

/// Wire-level contract for the auth feature. Deliberately mirrors what a
/// real REST auth API looks like (methods take/return primitives + domain
/// entities, no invented request/response DTO shapes) so that swapping
/// [AuthMockDataSource] for a Dio-backed implementation later is a
/// same-signature, same-callers change.
///
/// Throws a [Failure] (see core/errors) on any failure path — never a raw
/// exception — so [AuthRepositoryImpl] can map it uniformly regardless of
/// which implementation is behind this interface.
abstract interface class AuthRemoteDataSource {
  Future<({AuthUser user, AuthTokens tokens})> login({required String email, required String password});

  Future<({AuthUser user, AuthTokens tokens})> register(RegisterRequest request);

  Future<AuthTokens> refreshToken(String refreshToken);

  Future<AuthUser> currentUser(String accessToken);

  Future<void> logout(String accessToken);

  Future<void> requestOtp({required String destination});

  Future<bool> verifyOtp({required String destination, required String code});

  Future<void> resetPassword({required String destination, required String code, required String newPassword});
}
