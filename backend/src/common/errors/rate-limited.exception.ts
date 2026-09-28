import { HttpException, HttpStatus } from '@nestjs/common';
import { ApiErrorCode } from './api-error-codes';

/**
 * 429 thrown from a service. {@link HttpExceptionFilter} turns
 * {@link retryAfterSeconds} into the `Retry-After` header, which the app
 * reads to tell the user how long to wait.
 */
export class RateLimitedException extends HttpException {
  constructor(
    message: string,
    readonly retryAfterSeconds: number,
  ) {
    super(
      { message, code: ApiErrorCode.TOO_MANY_REQUESTS },
      HttpStatus.TOO_MANY_REQUESTS,
    );
  }
}
