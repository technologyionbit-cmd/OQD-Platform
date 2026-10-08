import {
  CanActivate,
  ExecutionContext,
  HttpException,
  HttpStatus,
  Injectable,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectThrottlerStorage, ThrottlerStorage } from '@nestjs/throttler';
import { createHash } from 'crypto';
import type { Request, Response } from 'express';
import { ApiErrorCode } from '../../common/errors/api-error-codes';
import type { AuthConfig } from '../../config/configuration';
import { normalizeJordanMobile } from '../dto/phone.rules';

const THROTTLER_NAME = 'login-phone';

/**
 * Per-account brute-force guard for sign-in (docs/backend/14-security.md:
 * "per-IP and per-account"). The global per-IP throttle alone lets an
 * attacker spread guesses at one account across many IPs.
 *
 * - Keyed on the normalized phone number (every accepted spelling counts
 *   as one), counted the same whether or not the account exists, so
 *   hitting the limit reveals nothing about which numbers are registered.
 * - A fixed window that expires on its own — never a permanent lockout,
 *   which would let anyone lock a victim out just by knowing their number.
 * - Shares the throttler's storage; keys are hashed so numbers aren't held
 *   in memory in the clear.
 */
@Injectable()
export class LoginAttemptsGuard implements CanActivate {
  private readonly limit: number;
  private readonly windowMs: number;

  constructor(
    @InjectThrottlerStorage() private readonly storage: ThrottlerStorage,
    config: ConfigService,
  ) {
    const auth = config.get<AuthConfig>('auth')!;
    this.limit = auth.loginMaxAttempts;
    this.windowMs = auth.loginAttemptWindowMinutes * 60_000;
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const http = context.switchToHttp();
    const phone = phoneOf(http.getRequest<Request>().body);
    // Malformed bodies are left to the ValidationPipe to reject.
    if (phone === null) return true;

    const key = createHash('sha256').update(`login:${phone}`).digest('hex');
    const { isBlocked, timeToBlockExpire } = await this.storage.increment(
      key,
      this.windowMs,
      this.limit,
      this.windowMs,
      THROTTLER_NAME,
    );

    if (isBlocked) {
      http
        .getResponse<Response>()
        .header('Retry-After', String(Math.max(1, timeToBlockExpire)));
      throw new HttpException(
        {
          message: 'Too many sign-in attempts. Try again later.',
          code: ApiErrorCode.TOO_MANY_REQUESTS,
        },
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }
    return true;
  }
}

/** Guards run before the ValidationPipe, so the body is still raw here. */
function phoneOf(body: unknown): string | null {
  if (typeof body !== 'object' || body === null) return null;
  const phone = (body as { phone?: unknown }).phone;
  return typeof phone === 'string' ? normalizeJordanMobile(phone) : null;
}
