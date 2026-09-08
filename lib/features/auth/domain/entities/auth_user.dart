import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';

part 'auth_user.freezed.dart';

/// Well-known demo-account IDs — mirrors `kDemoLawyerId` in
/// `lawyer_profile.dart` (that one identifies the lawyer *profile* used by
/// the marketplace/booking flows; these identify the signed-in *auth
/// user*). Lets features outside `auth/data` (e.g. the mock written-chat
/// reply simulation, which authors a message "as the lawyer" even when the
/// client is the one signed in) reference the demo identities without
/// reaching into `AuthMockDataSource` directly. Must stay in sync with the
/// accounts seeded there.
const kDemoClientUserId = 'u_client_1';
const kDemoLawyerUserId = 'u_lawyer_1';
const kDemoCompanyUserId = 'u_company_1';

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
