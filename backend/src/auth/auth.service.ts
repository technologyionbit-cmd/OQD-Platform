import { Injectable, UnprocessableEntityException } from '@nestjs/common';
import { ApiErrorCode } from '../common/errors/api-error-codes';
import { ConfigService } from '@nestjs/config';
import type {
  Prisma,
  User,
  UserRole,
  VerificationPurpose,
} from '@prisma/client';
import { forbidden, notFound, unauthorized } from '../common/errors/api-exceptions';
import { RateLimitedException } from '../common/errors/rate-limited.exception';
import type { AuthConfig } from '../config/configuration';
import { PrismaService } from '../prisma/prisma.service';
import type {
  AuthTokens,
  AuthUserView,
  RequestContext,
} from './auth.types';
import type {
  ChangePasswordDto,
  LoginDto,
  RefreshDto,
  LogoutDto,
  UpdateProfileDto,
} from './dto/credentials.dto';
import type {
  ForgotPasswordDto,
  ResetPasswordDto,
  VerifyOtpDto,
} from './dto/password-reset.dto';
import type { AccountType, RegisterDto } from './dto/register.dto';
import { PasswordService } from './services/password.service';
import { OtpService, type OtpIssueFilter } from './services/otp.service';
import { TokenService } from './services/token.service';

@Injectable()
export class AuthService {
  private readonly termsVersion: string;
  private readonly resendCooldownSeconds: number;
  private readonly resendMaxPerHour: number;

  constructor(
    private readonly prisma: PrismaService,
    private readonly passwords: PasswordService,
    private readonly tokens: TokenService,
    private readonly otp: OtpService,
    configService: ConfigService,
  ) {
    const auth = configService.get<AuthConfig>('auth')!;
    this.termsVersion = auth.termsVersion;
    this.resendCooldownSeconds = auth.otpResendCooldownSeconds;
    this.resendMaxPerHour = auth.otpMaxPerHour;
  }

  // ---------------------------------------------------------------------------
  // Registration
  // ---------------------------------------------------------------------------

  async register(
    dto: RegisterDto,
    ctx: RequestContext,
  ): Promise<{ user: AuthUserView; tokens: AuthTokens }> {
    if (dto.termsVersion !== this.termsVersion) {
      // The app showed an older terms text than the one now in force.
      throw this.fieldError(
        'termsVersion',
        'The terms have changed. Review and accept the current version.',
        ApiErrorCode.TERMS_VERSION_OUTDATED,
      );
    }

    const email = dto.email.trim().toLowerCase();
    await this.assertEmailAvailable(email);

    const role = this.roleFor(dto.accountType);
    const passwordHash = await this.passwords.hash(dto.password);
    const displayName =
      dto.accountType === 'company'
        ? dto.companyName!.trim()
        : dto.fullName!.trim();

    const user = await this.prisma
      .$transaction(async (tx) => {
        const created = await tx.user.create({
          data: {
            fullName: displayName,
            email,
            phone: dto.phone.trim(),
            passwordHash,
            role,
            termsAcceptedAt: new Date(),
            termsVersion: dto.termsVersion,
          },
        });

        if (dto.accountType === 'company') {
          const organization = await tx.organization.create({
            data: {
              name: displayName,
              commercialRegistrationNumber:
                dto.commercialRegistrationNumber!.trim(),
              ownerUserId: created.id,
            },
          });
          await tx.organizationMember.create({
            data: {
              organizationId: organization.id,
              userId: created.id,
              email,
              fullName: displayName,
              role: 'owner',
              status: 'active',
              joinedAt: new Date(),
            },
          });
        }

        if (dto.accountType === 'lawyer') {
          const barLicenseNumber = dto.barLicenseNumber!.trim();
          await tx.lawyerRegistrationDetail.create({
            data: {
              userId: created.id,
              barLicenseNumber,
              mainSpecialty: dto.mainSpecialty!,
            },
          });
          // Auto-create the LawyerProfile the marketplace reads from
          // (docs/backend/09-lawyers-marketplace.md §2) — unifies
          // LawyerProfile.userId with User.id 1:1 from day one, seeded
          // from the registration-time fields. Always starts `unverified`,
          // never defaults to verified (§3) — excluded from public search
          // until an admin verifies it.
          await tx.lawyerProfile.create({
            data: {
              userId: created.id,
              fullName: displayName,
              barLicenseNumber,
              verificationStatus: 'unverified',
              specialties: { create: [{ specialty: dto.mainSpecialty! }] },
            },
          });
        }

        return created;
      })
      .catch((error: unknown) => this.rethrowUniqueViolation(error));

    // Fire-and-forget email verification — never blocks registration
    // success (docs §2). Failure to "send" (log) must not fail the request.
    await this.otp
      .issue(email, 'emailVerification', user.id)
      .catch(() => undefined);

    const tokens = await this.tokens.issueSession(user.id, user.role, ctx);
    return { user: this.toView(user), tokens };
  }

  // ---------------------------------------------------------------------------
  // Login / session lifecycle
  // ---------------------------------------------------------------------------

  async login(
    dto: LoginDto,
    ctx: RequestContext,
  ): Promise<{ user: AuthUserView; tokens: AuthTokens }> {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email.trim().toLowerCase() },
    });

    // Same bcrypt work whether or not the account exists (timing-safe).
    const ok = await this.passwords.verifyOrBurn(
      dto.password,
      user?.passwordHash ?? null,
    );

    if (!user || !ok) {
      throw unauthorized('Invalid email or password.');
    }

    if (user.status !== 'active') {
      throw forbidden('This account is not active.', ApiErrorCode.ACCOUNT_INACTIVE);
    }

    const tokens = await this.tokens.issueSession(user.id, user.role, ctx);
    await this.prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    return { user: this.toView(user), tokens };
  }

  async refresh(
    dto: RefreshDto,
    ctx: RequestContext,
  ): Promise<{ tokens: AuthTokens }> {
    const tokens = await this.tokens.rotate(dto.refreshToken, ctx);
    return { tokens };
  }

  async logout(dto: LogoutDto): Promise<void> {
    await this.tokens.revokeByRawToken(dto.refreshToken);
  }

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------

  async me(userId: string): Promise<AuthUserView> {
    return this.toView(await this.activeUser(userId));
  }

  async updateProfile(
    userId: string,
    dto: UpdateProfileDto,
  ): Promise<AuthUserView> {
    const email = dto.email.trim().toLowerCase();
    const current = await this.prisma.user.findUnique({
      where: { id: userId },
    });
    if (!current) {
      throw notFound('Account not found.');
    }

    const emailChanged = current.email.toLowerCase() !== email;
    if (emailChanged) {
      await this.assertEmailAvailable(email);
    }

    const updated = await this.prisma.user
      .update({
        where: { id: userId },
        data: {
          fullName: dto.fullName.trim(),
          email,
          // A new address is unproven until its owner enters the code.
          ...(emailChanged ? { emailVerifiedAt: null } : {}),
        },
      })
      .catch((error: unknown) => this.rethrowUniqueViolation(error));

    if (emailChanged) {
      await this.otp
        .issue(email, 'emailVerification', userId)
        .catch(() => undefined);
    }
    return this.toView(updated);
  }

  // ---------------------------------------------------------------------------
  // Email verification
  // ---------------------------------------------------------------------------

  /** Marks the email verified when [code] is the account's latest code.
   *  Idempotent: an already-verified account just gets its view back. */
  async verifyEmail(userId: string, code: string): Promise<AuthUserView> {
    const user = await this.activeUser(userId);
    if (user.emailVerifiedAt) return this.toView(user);

    const result = await this.otp.consume(
      user.email,
      code,
      'emailVerification',
      user.id,
    );
    if (!result.valid) {
      throw this.invalidCode();
    }

    const verified = await this.prisma.user.update({
      where: { id: user.id },
      data: { emailVerifiedAt: new Date() },
    });
    return this.toView(verified);
  }

  /** Sends a new code within the send limits (see {@link assertCanSendCode};
   *  the registration code counts). A no-op for an already verified account. */
  async resendEmailVerification(userId: string): Promise<void> {
    const user = await this.activeUser(userId);
    if (user.emailVerifiedAt) return;

    await this.assertCanSendCode({ userId: user.id }, 'emailVerification');
    await this.otp.issue(user.email, 'emailVerification', user.id);
  }

  // ---------------------------------------------------------------------------
  // Password reset (emailed code)
  // ---------------------------------------------------------------------------

  /**
   * Emails a reset code when [email] belongs to an account. Known and
   * unknown addresses get the same 204, the same work and the same send
   * limits, so the answer never reveals whether an account exists.
   */
  async forgotPassword(dto: ForgotPasswordDto): Promise<void> {
    const email = dto.email.trim().toLowerCase();
    await this.assertCanSendCode({ destination: email }, 'passwordReset');
    const user = await this.prisma.user.findUnique({ where: { email } });
    await this.otp.issue(email, 'passwordReset', user?.id ?? null);
  }

  /** Checks the code before the app asks for a new password. Does not
   *  use the code up; wrong tries count toward its lock. */
  async verifyOtp(dto: VerifyOtpDto): Promise<void> {
    const result = await this.otp.verify(
      dto.email.trim().toLowerCase(),
      dto.code,
      'passwordReset',
    );
    if (!result.valid) {
      throw this.invalidCode();
    }
  }

  /**
   * Sets the new password, marks the email verified (the code proved the
   * user reads it) and signs the account out everywhere.
   */
  async resetPassword(dto: ResetPasswordDto): Promise<void> {
    const email = dto.email.trim().toLowerCase();
    const result = await this.otp.consume(email, dto.code, 'passwordReset');
    const user =
      result.valid && result.userId
        ? await this.prisma.user.findUnique({ where: { id: result.userId } })
        : null;
    // The code proves control of this address only while it is still the
    // account's email; after an email change it resets nothing.
    if (!user || user.email !== email) {
      throw this.invalidCode();
    }

    const passwordHash = await this.passwords.hash(dto.newPassword);
    await this.prisma.user.update({
      where: { id: user.id },
      data: {
        passwordHash,
        ...(user.emailVerifiedAt ? {} : { emailVerifiedAt: new Date() }),
      },
    });
    // Security-sensitive change: force re-login everywhere (docs §4).
    await this.tokens.revokeAllForUser(user.id);
  }

  /**
   * Send limits for emailed codes: one per cooldown, and a fixed number
   * per rolling hour for [filter] (an account or an address). Over the
   * limit it is a 429 whose Retry-After says when the next send fits.
   */
  private async assertCanSendCode(
    filter: OtpIssueFilter,
    purpose: VerificationPurpose,
  ): Promise<void> {
    const now = Date.now();
    const hourMs = 60 * 60 * 1000;
    const issued = await this.otp.issuedSince(
      filter,
      purpose,
      new Date(now - hourMs),
    );

    const last = issued.at(-1);
    const cooldownMs = this.resendCooldownSeconds * 1000;
    if (last && now - last.getTime() < cooldownMs) {
      throw new RateLimitedException(
        'Wait before requesting another code.',
        (cooldownMs - (now - last.getTime())) / 1000,
      );
    }
    if (issued.length >= this.resendMaxPerHour) {
      // The send that must leave the one-hour window before another fits.
      const blocking = issued[issued.length - this.resendMaxPerHour];
      throw new RateLimitedException(
        'Too many codes requested. Try again later.',
        (blocking.getTime() + hourMs - now) / 1000,
      );
    }
  }

  async changePassword(
    userId: string,
    sessionId: string,
    dto: ChangePasswordDto,
  ): Promise<void> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw unauthorized('Session expired. Please sign in again.');
    }

    const ok = await this.passwords.verify(
      dto.currentPassword,
      user.passwordHash,
    );
    if (!ok) {
      throw this.fieldError(
        'currentPassword',
        'Current password is incorrect.',
      );
    }

    const passwordHash = await this.passwords.hash(dto.newPassword);
    await this.prisma.user.update({
      where: { id: userId },
      data: { passwordHash },
    });
    // Keep the caller signed in, drop every other session (docs §5).
    await this.tokens.revokeAllForUser(userId, sessionId);
  }

  // ---------------------------------------------------------------------------
  // Active sessions
  // ---------------------------------------------------------------------------

  listSessions(userId: string, sessionId: string) {
    return this.tokens.listActiveSessions(userId, sessionId);
  }

  async revokeSession(userId: string, sessionId: string): Promise<void> {
    const revoked = await this.tokens.revokeSession(userId, sessionId);
    if (!revoked) {
      throw notFound('Session not found.');
    }
  }

  revokeOtherSessions(userId: string, sessionId: string): Promise<void> {
    return this.tokens.revokeAllForUser(userId, sessionId);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  private toView(user: User): AuthUserView {
    return {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      role: user.role,
      emailVerified: user.emailVerifiedAt !== null,
    };
  }

  /** The caller's account, or 401 when it is gone or no longer active. */
  private async activeUser(userId: string): Promise<User> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user || user.status !== 'active') {
      throw unauthorized('Session expired. Please sign in again.');
    }
    return user;
  }

  private roleFor(accountType: AccountType): UserRole {
    switch (accountType) {
      case 'company':
        return 'company';
      case 'lawyer':
        return 'lawyer';
      default:
        return 'client';
    }
  }

  private async assertEmailAvailable(email: string): Promise<void> {
    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) {
      throw this.emailTaken();
    }
  }

  private emailTaken(): UnprocessableEntityException {
    return this.fieldError(
      'email',
      'This email is already registered.',
      ApiErrorCode.EMAIL_ALREADY_REGISTERED,
    );
  }

  private invalidCode(): UnprocessableEntityException {
    return this.fieldError(
      'code',
      'Invalid or expired code.',
      ApiErrorCode.INVALID_VERIFICATION_CODE,
    );
  }

  /** A 422 naming the offending field. [code] tells the app which
   *  localized message to show; the English text is for logs only. */
  private fieldError(
    field: string,
    message: string,
    code: ApiErrorCode = ApiErrorCode.VALIDATION_ERROR,
  ): UnprocessableEntityException {
    return new UnprocessableEntityException({
      message,
      code,
      errors: { [field]: [message] },
    });
  }

  /** Turns a unique-constraint race (two sign-ups with the same value at
   *  once, past the pre-checks) into the same 422 the pre-check gives. */
  private rethrowUniqueViolation(error: unknown): never {
    if (this.isPrismaKnownError(error) && error.code === 'P2002') {
      const rawTarget = error.meta?.target;
      const target = Array.isArray(rawTarget)
        ? rawTarget.join(',')
        : typeof rawTarget === 'string'
          ? rawTarget
          : '';
      if (/commercial_?registration_?number/i.test(target)) {
        throw this.fieldError(
          'commercialRegistrationNumber',
          'This commercial registration number is already in use.',
          ApiErrorCode.COMMERCIAL_REGISTRATION_TAKEN,
        );
      }
      if (/bar_?license_?number/i.test(target)) {
        throw this.fieldError(
          'barLicenseNumber',
          'This bar license number is already in use.',
          ApiErrorCode.BAR_LICENSE_TAKEN,
        );
      }
      if (target.includes('email')) {
        throw this.emailTaken();
      }
    }
    throw error as Error;
  }

  private isPrismaKnownError(
    error: unknown,
  ): error is Prisma.PrismaClientKnownRequestError {
    return (
      typeof error === 'object' &&
      error !== null &&
      'code' in error &&
      typeof error.code === 'string'
    );
  }
}
