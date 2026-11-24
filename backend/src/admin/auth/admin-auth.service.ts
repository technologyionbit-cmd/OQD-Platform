import { Injectable } from '@nestjs/common';
import { forbidden, unauthorized } from '../../common/errors/api-exceptions';
import type { AuthUserView, RequestContext } from '../../auth/auth.types';
import type { LoginDto } from '../../auth/dto/credentials.dto';
import { AuthService } from '../../auth/auth.service';
import { TokenService } from '../../auth/services/token.service';
import { PrismaService } from '../../prisma/prisma.service';

/** What the admin app gets in the body. The refresh token never is: the
 *  controller puts it in an httpOnly cookie. */
/** What the signed-in admin may do; the app hides what is not allowed. */
export interface AdminAccessView {
  fullAccess: boolean;
  permissions: string[];
}

export interface AdminSession {
  user: AuthUserView;
  access: AdminAccessView;
  accessToken: string;
  /** For the controller's cookie only. */
  refreshToken: string;
}

const NOT_ADMIN = 'This account is not an admin.';

/**
 * Sign-in for the admin web app. It reuses the app's own login and token
 * rotation, then refuses anyone who is not an admin, ending the session it
 * just opened so a non-admin never keeps a live token from this door.
 */
@Injectable()
export class AdminAuthService {
  constructor(
    private readonly auth: AuthService,
    private readonly tokens: TokenService,
    private readonly prisma: PrismaService,
  ) {}

  async login(dto: LoginDto, ctx: RequestContext): Promise<AdminSession> {
    const { user, tokens } = await this.auth.login(dto, ctx);
    if (user.role !== 'admin') {
      await this.tokens.revokeByRawToken(tokens.refreshToken);
      throw forbidden(NOT_ADMIN);
    }
    const account = await this.prisma.user.findUniqueOrThrow({
      where: { id: user.id },
      select: { adminFullAccess: true, adminPermissions: true },
    });
    return {
      user,
      access: {
        fullAccess: account.adminFullAccess,
        permissions: account.adminPermissions,
      },
      ...tokens,
    };
  }

  async refresh(rawRefresh: string, ctx: RequestContext): Promise<AdminSession> {
    const tokens = await this.tokens.rotate(rawRefresh, ctx);
    const payload = this.tokens.verifyAccessToken(tokens.accessToken);
    const account = await this.prisma.user.findUnique({
      where: { id: payload.sub },
    });
    if (!account || account.deletedAt || account.status !== 'active') {
      await this.tokens.revokeByRawToken(tokens.refreshToken);
      throw unauthorized('Session expired. Please sign in again.');
    }
    if (account.role !== 'admin') {
      await this.tokens.revokeByRawToken(tokens.refreshToken);
      throw forbidden(NOT_ADMIN);
    }
    return {
      user: {
        id: account.id,
        fullName: account.fullName,
        email: account.email,
        phone: account.phone,
        role: account.role,
        phoneVerified: account.phoneVerifiedAt !== null,
      },
      access: {
        fullAccess: account.adminFullAccess,
        permissions: account.adminPermissions,
      },
      ...tokens,
    };
  }

  async logout(rawRefresh: string): Promise<void> {
    await this.tokens.revokeByRawToken(rawRefresh);
  }
}
