import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';

part 'auth_user.freezed.dart';

/// The signed-in user's identity, as far as the app needs it for
/// navigation/display. Field set intentionally minimal for the foundation —
/// grows once the real backend contract (and the profile feature) exists.
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String fullName,
    required String email,
    required UserRole role,
  }) = _AuthUser;
}
