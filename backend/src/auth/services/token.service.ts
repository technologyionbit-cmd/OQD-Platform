import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { createHash, randomBytes } from 'node:crypto';
import type { RefreshToken, UserRole } from '@prisma/client';
import { unauthorized } from '../../common/errors/api-exceptions';
import { PrismaService } from '../../prisma/prisma.service';
import type { JwtConfig } from '../../config/configuration';
import type {
  AccessTokenPayload,
  AuthTokens,
  RequestContext,
} from '../auth.types';

/**
 * Issues and rotates the access/refresh pair.
 *
 * - Access: short-lived JWT (`JWT_ACCESS_TTL`), carries `sub`/`role`/`sid`.
 * - Refresh: opaque 48-byte random string, only its SHA-256 hash is stored
 *   in `refresh_tokens`. Rotating on every use (issue new, revoke old) lets
 *   a replayed — already-revoked — refresh token be detected as compromise,
 *   at which point the whole session family for that user is revoked.
 */
@Injectable()
export class TokenService {
  private readonly logger = new Logger(TokenService.name);
  private readonly jwtConfig: JwtConfig;

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    configService: ConfigService,
  ) {
    this.jwtConfig = configService.get<JwtConfig>('jwt')!;
  }

  /** Create a brand-new session (login / register). */
  async issueSession(
    userId: string,
    role: UserRole,
    ctx: RequestContext,
  ): Promise<AuthTokens> {
    const rawRefresh = this.generateRawRefreshToken();
    const session = await this.prisma.refreshToken.create({
      data: {
        userId,
        refreshTokenHash: this.hashRefreshToken(rawRefresh),
        deviceLabel: ctx.deviceLabel,
        ipAddress: ctx.ipAddress,
        expiresAt: this.refreshExpiry(),
      },
    });
    return this.buildTokens(userId, role, session.id, rawRefresh);
  }

  /** Rotate an existing session from a presented raw refresh token. */
  async rotate(rawRefresh: string, ctx: RequestContext): Promise<AuthTokens> {
    const hash = this.hashRefreshToken(rawRefresh);
    const existing = await this.prisma.refreshToken.findFirst({
      where: { refreshTokenHash: hash },
      include: { user: { select: { role: true, status: true } } },
    });

    if (!existing) {
      throw unauthorized('Session expired. Please sign in again.');
    }

    if (existing.revokedAt) {
      // A revoked token presented again == replay. Revoke the whole family.
      this.logger.warn(
        `Refresh token reuse detected for user ${existing.userId} — revoking all sessions`,
      );
      await this.revokeAllForUser(existing.userId);
      throw unauthorized('Session expired. Please sign in again.');
    }

    if (existing.expiresAt.getTime() <= Date.now()) {
      throw unauthorized('Session expired. Please sign in again.');
    }

    if (existing.user.status !== 'active') {
      throw unauthorized('Session expired. Please sign in again.');
    }

    const rawNext = this.generateRawRefreshToken();
    const next = await this.prisma.$transaction(async (tx) => {
      await tx.refreshToken.update({
        where: { id: existing.id },
        data: { revokedAt: new Date(), lastUsedAt: new Date() },
      });
      return tx.refreshToken.create({
        data: {
          userId: existing.userId,
          refreshTokenHash: this.hashRefreshToken(rawNext),
          deviceLabel: ctx.deviceLabel ?? existing.deviceLabel,
          ipAddress: ctx.ipAddress ?? existing.ipAddress,
          expiresAt: this.refreshExpiry(),
        },
      });
    });

    return this.buildTokens(
      existing.userId,
      existing.user.role,
      next.id,
      rawNext,
    );
  }

  /** logout — revoke exactly the session behind the presented refresh token. */
  async revokeByRawToken(rawRefresh: string): Promise<void> {
    const hash = this.hashRefreshToken(rawRefresh);
    await this.prisma.refreshToken.updateMany({
      where: { refreshTokenHash: hash, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  async revokeSession(userId: string, sessionId: string): Promise<boolean> {
    const result = await this.prisma.refreshToken.updateMany({
      where: { id: sessionId, userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
    return result.count > 0;
  }

  async revokeAllForUser(userId: string, exceptId?: string): Promise<void> {
    await this.prisma.refreshToken.updateMany({
      where: {
        userId,
        revokedAt: null,
        ...(exceptId ? { id: { not: exceptId } } : {}),
      },
      data: { revokedAt: new Date() },
    });
  }

  async listActiveSessions(
    userId: string,
    currentSessionId: string,
  ): Promise<
    Array<{
      id: string;
      deviceLabel: string | null;
      ipAddress: string | null;
      createdAt: Date;
      lastUsedAt: Date | null;
      current: boolean;
    }>
  > {
    const sessions = await this.prisma.refreshToken.findMany({
      where: { userId, revokedAt: null, expiresAt: { gt: new Date() } },
      orderBy: { createdAt: 'desc' },
    });
    return sessions.map((s: RefreshToken) => ({
      id: s.id,
      deviceLabel: s.deviceLabel,
      ipAddress: s.ipAddress,
      createdAt: s.createdAt,
      lastUsedAt: s.lastUsedAt,
      current: s.id === currentSessionId,
    }));
  }

  verifyAccessToken(token: string): AccessTokenPayload {
    try {
      // Secret + expiry come from JwtModule.registerAsync (auth.module.ts).
      return this.jwt.verify<AccessTokenPayload>(token);
    } catch {
      throw unauthorized('Session expired. Please sign in again.');
    }
  }

  /** True while the session (refresh-token row) behind an access token is
   *  still live. Lets "logout everywhere" / password reset take effect
   *  immediately rather than waiting out the access token's TTL. */
  async isSessionActive(sessionId: string): Promise<boolean> {
    const session = await this.prisma.refreshToken.findFirst({
      where: {
        id: sessionId,
        revokedAt: null,
        expiresAt: { gt: new Date() },
      },
      select: { id: true },
    });
    return session !== null;
  }

  private buildTokens(
    userId: string,
    role: UserRole,
    sessionId: string,
    rawRefresh: string,
  ): AuthTokens {
    const payload: AccessTokenPayload = { sub: userId, role, sid: sessionId };
    return { accessToken: this.jwt.sign(payload), refreshToken: rawRefresh };
  }

  private generateRawRefreshToken(): string {
    return randomBytes(48).toString('base64url');
  }

  private hashRefreshToken(raw: string): string {
    return createHash('sha256').update(raw).digest('hex');
  }

  private refreshExpiry(): Date {
    return new Date(
      Date.now() + this.jwtConfig.refreshTtlDays * 24 * 60 * 60 * 1000,
    );
  }
}
