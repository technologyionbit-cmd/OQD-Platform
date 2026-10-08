import type { UserRole } from '@prisma/client';

/** Shape returned to the client for the signed-in user (docs §1). */
export interface AuthUserView {
  id: string;
  fullName: string;
  email: string;
  /** +9627XXXXXXXX — signs the account in and receives every code. Null
   *  only for old accounts whose number could not be normalized. */
  phone: string | null;
  role: UserRole;
  /** False until the user enters the code texted to [phone]. Sensitive
   *  actions answer 403 PHONE_NOT_VERIFIED until then. */
  phoneVerified: boolean;
}

/** Access + refresh pair returned by login/register/refresh. */
export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

/** JWT access-token payload. `sid` is the RefreshToken row id the access
 *  token was issued alongside — lets `/auth/sessions` mark the caller's
 *  own session as "current" and lets "revoke others" keep it. */
export interface AccessTokenPayload {
  sub: string;
  role: UserRole;
  sid: string;
}

/** Attached to `request.user` by JwtAuthGuard. */
export interface AuthenticatedUser {
  id: string;
  role: UserRole;
  sessionId: string;
}

/** Caller device/network context captured on each new session. */
export interface RequestContext {
  deviceLabel: string | null;
  ipAddress: string | null;
}
