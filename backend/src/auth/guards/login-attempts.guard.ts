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

const THROTTLER_NAME = 'login-email';

/**
 * Per-account brute-force guard for sign-in (docs/backend/14-security.md:
 * "per-IP and per-email"). The global per-IP throttle alone lets an
 * attacker spread guesses at one account across many IPs.
 *
 * - Keyed on the normalized email, counted the same whether or not the
 *   account exists, so hitting the limit reveals nothing about which
 *   emails are registered.
 * - A fixed window that expires on its own — never a permanent lockout,
 *   which would let anyone lock a victim out just by knowing their email.
 * - Shares the throttler's storage; keys are hashed so emails aren't held
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
    const email = normalizeEmail(http.getRequest<Request>().body);
    // Malformed bodies are left to the ValidationPipe to reject.
    if (email === null) return true;

    const key = createHash('sha256').update(`login:${email}`).digest('hex');
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

function normalizeEmail(body: unknown): string | null {
  if (typeof body !== 'object' || body === null) return null;
  const email = (body as { email?: unknown }).email;
  if (typeof email !== 'string') return null;
  const normalized = email.trim().toLowerCase();
  return normalized.length > 0 && normalized.length <= 254 ? normalized : null;
}
