import 'package:aqd_admin/features/auth/domain/admin_user.dart';

/// Admin sign-in. All methods throw a `Failure` on error.
abstract interface class AuthRepository {
  /// Throws `ForbiddenFailure` when the credentials are right but the
  /// account is not an admin.
  Future<AdminUser> login({required String phone, required String password});

  /// Restores the session from the refresh cookie; null when there is none
  /// (or it is no longer valid).
  Future<AdminUser?> restoreSession();

  Future<void> logout();
}
