import {
  ForbiddenException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
  UnprocessableEntityException,
} from '@nestjs/common';
import type { Prisma, User, UserRole } from '@prisma/client';
import { ApiErrorCode } from '../common/errors/api-error-codes';
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
import { OtpService } from './services/otp.service';
import { TokenService } from './services/token.service';

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly passwords: PasswordService,
    private readonly tokens: TokenService,
    private readonly otp: OtpService,
  ) {}

  // ---------------------------------------------------------------------------
  // Registration
  // ---------------------------------------------------------------------------

  async register(
    dto: RegisterDto,
    ctx: RequestContext,
  ): Promise<{ user: AuthUserView; tokens: AuthTokens }> {
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
      throw new UnauthorizedException({
        message: 'Invalid email or password.',
        code: ApiErrorCode.UNAUTHORIZED,
      });
    }

    if (user.status !== 'active') {
      throw new ForbiddenException({
        message: 'This account is not active.',
        code: ApiErrorCode.ACCOUNT_INACTIVE,
      });
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
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user || user.status !== 'active') {
      throw new UnauthorizedException({
        message: 'Session expired. Please sign in again.',
        code: ApiErrorCode.UNAUTHORIZED,
      });
    }
    return this.toView(user);
  }

  async updateProfile(
    userId: string,
    dto: UpdateProfileDto,
  ): Promise<AuthUserView> {
    const email = dto.email.trim().toLowerCase();
    const clash = await this.prisma.user.findUnique({ where: { email } });
    if (clash && clash.id !== userId) {
      throw this.fieldError('email', 'This email is already registered.');
    }

    try {
      const updated = await this.prisma.user.update({
        where: { id: userId },
        data: { fullName: dto.fullName.trim(), email },
      });
      return this.toView(updated);
    } catch (error) {
      if (this.isRecordNotFound(error)) {
        throw new NotFoundException({
          message: 'Account not found.',
          code: ApiErrorCode.NOT_FOUND,
        });
      }
      throw error;
    }
  }

  // ---------------------------------------------------------------------------
  // Password reset (OTP)
  // ---------------------------------------------------------------------------

  async forgotPassword(dto: ForgotPasswordDto): Promise<void> {
    const destination = dto.destination.trim();
    const user = await this.findByDestination(destination);
    // Always issue against the destination (even with no user) so response
    // timing/shape can't be used to enumerate accounts (docs §4).
    await this.otp.issue(destination, 'passwordReset', user?.id ?? null);
  }

  async verifyOtp(dto: VerifyOtpDto): Promise<{ valid: boolean }> {
    const result = await this.otp.verify(
      dto.destination.trim(),
      dto.code,
      'passwordReset',
    );
    return { valid: result.valid };
  }

  async resetPassword(dto: ResetPasswordDto): Promise<void> {
    const destination = dto.destination.trim();
    const result = await this.otp.consume(
      destination,
      dto.code,
      'passwordReset',
    );
    if (!result.valid) {
      throw this.fieldError('code', 'Invalid or expired code.');
    }

    const user =
      (result.userId
        ? await this.prisma.user.findUnique({ where: { id: result.userId } })
        : null) ?? (await this.findByDestination(destination));

    if (!user) {
      // Valid code but no account (shouldn't normally happen) — succeed
      // silently rather than leak that the destination is unknown.
      return;
    }

    const passwordHash = await this.passwords.hash(dto.newPassword);
    await this.prisma.user.update({
      where: { id: user.id },
      data: { passwordHash },
    });
    // Security-sensitive change: force re-login everywhere (docs §4).
    await this.tokens.revokeAllForUser(user.id);
  }

  async changePassword(
    userId: string,
    sessionId: string,
    dto: ChangePasswordDto,
  ): Promise<void> {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new UnauthorizedException({
        message: 'Session expired. Please sign in again.',
        code: ApiErrorCode.UNAUTHORIZED,
      });
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
      throw new NotFoundException({
        message: 'Session not found.',
        code: ApiErrorCode.NOT_FOUND,
      });
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
    };
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
      throw this.fieldError('email', 'This email is already registered.');
    }
  }

  private findByDestination(destination: string): Promise<User | null> {
    if (EMAIL_RE.test(destination)) {
      return this.prisma.user.findUnique({
        where: { email: destination.toLowerCase() },
      });
    }
    return this.prisma.user.findFirst({ where: { phone: destination } });
  }

  private fieldError(
    field: string,
    message: string,
  ): UnprocessableEntityException {
    return new UnprocessableEntityException({
      message: 'Validation failed',
      code: ApiErrorCode.VALIDATION_ERROR,
      errors: { [field]: [message] },
    });
  }

  private rethrowUniqueViolation(error: unknown): never {
    if (
      this.isPrismaKnownError(error) &&
      error.code === 'P2002' &&
      Array.isArray(error.meta?.target)
    ) {
      const target = (error.meta.target as string[]).join(',');
      if (target.includes('commercial_registration_number')) {
        throw this.fieldError(
          'commercialRegistrationNumber',
          'This commercial registration number is already in use.',
        );
      }
      if (target.includes('bar_license_number')) {
        throw this.fieldError(
          'barLicenseNumber',
          'This bar license number is already in use.',
        );
      }
      if (target.includes('email')) {
        throw this.fieldError('email', 'This email is already registered.');
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

  private isRecordNotFound(error: unknown): boolean {
    return this.isPrismaKnownError(error) && error.code === 'P2025';
  }
}
