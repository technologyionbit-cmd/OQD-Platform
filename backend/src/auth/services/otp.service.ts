import {
  Injectable,
  Logger,
  UnprocessableEntityException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHash, randomInt } from 'node:crypto';
import type { VerificationChannel, VerificationPurpose } from '@prisma/client';
import { ApiErrorCode } from '../../common/errors/api-error-codes';
import { PrismaService } from '../../prisma/prisma.service';
import type { AuthConfig } from '../../config/configuration';

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

export interface OtpVerification {
  valid: boolean;
  userId: string | null;
}

/**
 * One-time codes for password reset and email/phone verification.
 *
 * Codes are 6 numeric digits (mirrors the frontend's OtpVerificationScreen),
 * stored only as a SHA-256 hash in `verification_codes`, expire after
 * `OTP_TTL_MINUTES`, and lock out after `OTP_MAX_ATTEMPTS` failed tries.
 *
 * No email/SMS provider is wired in this phase — the generated code is
 * written to the server log (dev only). Swapping in a real provider is a
 * change confined to {@link deliver}.
 */
@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);
  private readonly ttlMinutes: number;
  private readonly maxAttempts: number;
  private readonly isProduction: boolean;

  /** Dev/test only — last code issued per destination, so local manual
   *  testing and e2e specs can complete the reset flow without an email
   *  provider. Never populated in production, never exposed over HTTP. */
  private readonly devCodes = new Map<string, string>();

  constructor(
    private readonly prisma: PrismaService,
    configService: ConfigService,
  ) {
    const cfg = configService.get<AuthConfig>('auth')!;
    this.ttlMinutes = cfg.otpTtlMinutes;
    this.maxAttempts = cfg.otpMaxAttempts;
    this.isProduction =
      configService.get<{ isProduction: boolean }>('app')!.isProduction;
  }

  /** Dev/test helper — see {@link devCodes}. Returns undefined in production. */
  peekDevCode(destination: string): string | undefined {
    return this.isProduction ? undefined : this.devCodes.get(destination.trim());
  }

  channelFor(destination: string): VerificationChannel {
    return EMAIL_RE.test(destination.trim()) ? 'email' : 'sms';
  }

  /** Issue and "send" a code. Caller must not reveal whether the
   *  destination maps to a real account. */
  async issue(
    destination: string,
    purpose: VerificationPurpose,
    userId: string | null,
  ): Promise<void> {
    const code = randomInt(0, 1_000_000).toString().padStart(6, '0');
    // Only the newest code for a destination+purpose is ever checked (see
    // latestUsable), so issuing a new one retires the previous one.
    await this.prisma.verificationCode.create({
      data: {
        userId,
        destination: destination.trim(),
        channel: this.channelFor(destination),
        codeHash: this.hash(code),
        purpose,
        expiresAt: new Date(Date.now() + this.ttlMinutes * 60 * 1000),
      },
    });
    if (!this.isProduction) {
      this.devCodes.set(destination.trim(), code);
    }
    this.deliver(destination, code, purpose);
  }

  /** Check a code without consuming it (the verify-otp screen step).
   *  With [userId], only a code issued to that account counts. */
  async verify(
    destination: string,
    code: string,
    purpose: VerificationPurpose,
    userId?: string,
  ): Promise<OtpVerification> {
    const record = await this.latestUsable(destination, purpose, userId);
    if (!record) {
      return { valid: false, userId: null };
    }

    if (record.attemptCount >= this.maxAttempts) {
      throw new UnprocessableEntityException({
        message: 'Too many attempts. Request a new code.',
        code: ApiErrorCode.VERIFICATION_CODE_LOCKED,
        errors: { code: ['Too many attempts. Request a new code.'] },
      });
    }

    if (record.codeHash !== this.hash(code)) {
      await this.prisma.verificationCode.update({
        where: { id: record.id },
        data: { attemptCount: { increment: 1 } },
      });
      return { valid: false, userId: null };
    }

    return { valid: true, userId: record.userId };
  }

  /** Validate and consume a code (the password-reset step). */
  async consume(
    destination: string,
    code: string,
    purpose: VerificationPurpose,
    userId?: string,
  ): Promise<OtpVerification> {
    const result = await this.verify(destination, code, purpose, userId);
    if (!result.valid) {
      return result;
    }
    const record = await this.latestUsable(destination, purpose, userId);
    if (record) {
      await this.prisma.verificationCode.update({
        where: { id: record.id },
        data: { consumedAt: new Date() },
      });
    }
    return result;
  }

  /** When each code for [purpose] was issued to [userId] since [since],
   *  oldest first — the input for per-account resend limits. */
  async issuedSince(
    userId: string,
    purpose: VerificationPurpose,
    since: Date,
  ): Promise<Date[]> {
    const rows = await this.prisma.verificationCode.findMany({
      where: { userId, purpose, createdAt: { gte: since } },
      select: { createdAt: true },
      orderBy: { createdAt: 'asc' },
    });
    return rows.map((row) => row.createdAt);
  }

  private latestUsable(
    destination: string,
    purpose: VerificationPurpose,
    userId?: string,
  ) {
    return this.prisma.verificationCode.findFirst({
      where: {
        destination: destination.trim(),
        purpose,
        ...(userId === undefined ? {} : { userId }),
        consumedAt: null,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  private hash(code: string): string {
    return createHash('sha256').update(code).digest('hex');
  }

  private deliver(
    destination: string,
    code: string,
    purpose: VerificationPurpose,
  ): void {
    this.logger.log(
      `[dev] ${purpose} code for ${destination}: ${code} (expires in ${this.ttlMinutes}m)`,
    );
  }
}
