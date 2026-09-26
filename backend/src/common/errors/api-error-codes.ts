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
