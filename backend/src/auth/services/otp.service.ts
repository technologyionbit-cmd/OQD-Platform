import { Injectable, Logger } from '@nestjs/common';
import { ApiErrorCode } from '../../common/errors/api-error-codes';
import { ConfigService } from '@nestjs/config';
import { createHash, randomInt, timingSafeEqual } from 'node:crypto';
import type { VerificationChannel, VerificationPurpose } from '@prisma/client';
import { validationFailed } from '../../common/errors/api-exceptions';
import { PrismaService } from '../../prisma/prisma.service';
import type { AuthConfig } from '../../config/configuration';

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

export interface OtpVerification {
  valid: boolean;
  userId: string | null;
}

/** Which codes a send limit counts: an account's, or an address's. */
export type OtpIssueFilter = { userId: string } | { destination: string };

/**
 * One-time codes for password reset and email/phone verification.
 *
 * Codes are 6 numeric digits (mirrors the frontend's OtpCodeField), stored
 * only as a SHA-256 hash in `verification_codes`, expire after
 * `OTP_TTL_MINUTES`, and lock out after `OTP_MAX_ATTEMPTS` failed tries.
 *
 * No email/SMS provider is wired in this phase — the generated code is
 * written to the server log. Swapping in a real provider is a change
 * confined to {@link deliver}.
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

  /**
   * Issue a code and send it. A code for no account ([userId] null) is
   * stored but never sent: the row keeps the request's cost and the send
   * limits the same for unknown addresses, so neither reveals whether an
   * account exists, and nobody can use the app to mail strangers.
   */
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
    if (userId !== null) {
      this.deliver(destination, code, purpose);
    }
  }

  /** Check a code without consuming it (the verify-otp screen step).
   *  With [userId], only a code issued to that account counts. */
  async verify(
    destination: string,
    code: string,
    purpose: VerificationPurpose,
    userId?: string,
  ): Promise<OtpVerification> {
    const match = await this.check(destination, code, purpose, userId);
    return { valid: match !== null, userId: match?.userId ?? null };
  }

  /** Validate and consume a code (the password-reset step). Of two
   *  requests racing with the same code, only one gets `valid: true`. */
  async consume(
    destination: string,
    code: string,
    purpose: VerificationPurpose,
    userId?: string,
  ): Promise<OtpVerification> {
    const match = await this.check(destination, code, purpose, userId);
    if (!match) {
      return { valid: false, userId: null };
    }
    const claimed = await this.prisma.verificationCode.updateMany({
      where: { id: match.id, consumedAt: null },
      data: { consumedAt: new Date() },
    });
    return claimed.count === 1
      ? { valid: true, userId: match.userId }
      : { valid: false, userId: null };
  }

  /** When each code for [purpose] matching [filter] was issued since
   *  [since], oldest first — the input for send limits. */
  async issuedSince(
    filter: OtpIssueFilter,
    purpose: VerificationPurpose,
    since: Date,
  ): Promise<Date[]> {
    const rows = await this.prisma.verificationCode.findMany({
      where: { ...filter, purpose, createdAt: { gte: since } },
      select: { createdAt: true },
      orderBy: { createdAt: 'asc' },
    });
    return rows.map((row) => row.createdAt);
  }

  /** The matching code's row when [code] is right, else null. Throws
   *  VERIFICATION_CODE_LOCKED once the code has no tries left. */
  private async check(
    destination: string,
    code: string,
    purpose: VerificationPurpose,
    userId?: string,
  ): Promise<{ id: string; userId: string | null } | null> {
    const record = await this.latestUsable(destination, purpose, userId);
    if (!record) {
      return null;
    }

    // Take a try before comparing, in one conditional update, so parallel
    // guesses can never get past OTP_MAX_ATTEMPTS.
    const reserved = await this.prisma.verificationCode.updateMany({
      where: { id: record.id, attemptCount: { lt: this.maxAttempts } },
      data: { attemptCount: { increment: 1 } },
    });
    if (reserved.count === 0) {
      throw validationFailed({ code: ['Too many attempts. Request a new code.'] }, 'Too many attempts. Request a new code.', ApiErrorCode.VERIFICATION_CODE_LOCKED);
    }

    if (!this.matches(record.codeHash, code)) {
      return null;
    }
    // Only wrong codes count: checking the right one on the code screen,
    // then again on reset, must not use up the user's tries.
    await this.prisma.verificationCode.update({
      where: { id: record.id },
      data: { attemptCount: { decrement: 1 } },
    });
    return { id: record.id, userId: record.userId };
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

  private matches(codeHash: string, code: string): boolean {
    return timingSafeEqual(
      Buffer.from(codeHash, 'hex'),
      Buffer.from(this.hash(code), 'hex'),
    );
  }

  /** A real provider must send in the background: awaiting it here would
   *  make forgot-password slower for real accounts than for unknown ones. */
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
