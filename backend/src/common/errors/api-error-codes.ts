/**
 * Machine-readable error codes for the API error envelope.
 * Status-code mapping must match the frontend's ApiErrorMapper exactly —
 * see docs/backend/05-api-design.md §4.
 */
export enum ApiErrorCode {
  BAD_REQUEST = 'BAD_REQUEST',
  UNAUTHORIZED = 'UNAUTHORIZED',
  FORBIDDEN = 'FORBIDDEN',
  NOT_FOUND = 'NOT_FOUND',
  CONFLICT = 'CONFLICT',
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  TIMEOUT = 'TIMEOUT',
  TOO_MANY_REQUESTS = 'TOO_MANY_REQUESTS',
  SERVER_ERROR = 'SERVER_ERROR',
  /** Sign-in with correct credentials for a suspended/deactivated account. */
  ACCOUNT_INACTIVE = 'ACCOUNT_INACTIVE',
  /** 422 — registration/profile email belongs to another account. */
  EMAIL_ALREADY_REGISTERED = 'EMAIL_ALREADY_REGISTERED',
  /** 422 — registration phone number belongs to another account. */
  PHONE_ALREADY_REGISTERED = 'PHONE_ALREADY_REGISTERED',
  /** 422 — company registration number belongs to another organization. */
  COMMERCIAL_REGISTRATION_TAKEN = 'COMMERCIAL_REGISTRATION_TAKEN',
  /** 422 — bar license number belongs to another lawyer. */
  BAR_LICENSE_TAKEN = 'BAR_LICENSE_TAKEN',
  /** 422 — the client accepted a terms version that is no longer current. */
  TERMS_VERSION_OUTDATED = 'TERMS_VERSION_OUTDATED',
  /** 422 — one-time code is wrong or expired. */
  INVALID_VERIFICATION_CODE = 'INVALID_VERIFICATION_CODE',
  /** 422 — too many wrong tries on the current code; a new one is needed. */
  VERIFICATION_CODE_LOCKED = 'VERIFICATION_CODE_LOCKED',
  /** 403 — the action needs a verified phone number. */
  PHONE_NOT_VERIFIED = 'PHONE_NOT_VERIFIED',
  /** 409 — the contract's status does not allow this action (e.g. editing
   *  a contract that is no longer a draft, signing twice). */
  CONTRACT_STATUS_CONFLICT = 'CONTRACT_STATUS_CONFLICT',
}

const STATUS_TO_CODE: Readonly<Record<number, ApiErrorCode>> = {
  400: ApiErrorCode.BAD_REQUEST,
  401: ApiErrorCode.UNAUTHORIZED,
  403: ApiErrorCode.FORBIDDEN,
  404: ApiErrorCode.NOT_FOUND,
  408: ApiErrorCode.TIMEOUT,
  409: ApiErrorCode.CONFLICT,
  422: ApiErrorCode.VALIDATION_ERROR,
  429: ApiErrorCode.TOO_MANY_REQUESTS,
};

export function resolveApiErrorCode(status: number): ApiErrorCode {
  const known = STATUS_TO_CODE[status];
  if (known) {
    return known;
  }
  return status >= 500 ? ApiErrorCode.SERVER_ERROR : ApiErrorCode.BAD_REQUEST;
}
