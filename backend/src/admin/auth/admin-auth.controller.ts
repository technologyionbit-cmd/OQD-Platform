import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Post,
  Req,
  Res,
  UseGuards,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  ApiForbiddenResponse,
  ApiNoContentResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import type { CookieOptions, Request, Response } from 'express';
import type { RequestContext } from '../../auth/auth.types';
import { ClientContext } from '../../auth/decorators/client-context.decorator';
import { LoginDto } from '../../auth/dto/credentials.dto';
import { LoginAttemptsGuard } from '../../auth/guards/login-attempts.guard';
import { unauthorized } from '../../common/errors/api-exceptions';
import { ApiErrorResponseDto } from '../../common/openapi/api-error.dto';
import type { AppConfig, JwtConfig } from '../../config/configuration';
import { AuditService } from '../audit/audit.service';
import { AdminAuthService, type AdminSession } from './admin-auth.service';
import { AdminOriginGuard } from './admin-origin.guard';

export const ADMIN_REFRESH_COOKIE = 'aqd_admin_rt';
/** The cookie is only ever sent to these routes. */
const COOKIE_PATH = '/v1/admin-auth';

const STRICT_THROTTLE = { default: { limit: 8, ttl: 60_000 } };
const REFRESH_THROTTLE = { default: { limit: 30, ttl: 60_000 } };

/** Reads one cookie without a parser dependency. */
export function readCookie(
  header: string | undefined,
  name: string,
): string | null {
  if (!header) return null;
  for (const part of header.split(';')) {
    const index = part.indexOf('=');
    if (index > 0 && part.slice(0, index).trim() === name) {
      try {
        return decodeURIComponent(part.slice(index + 1).trim());
      } catch {
        return null;
      }
    }
  }
  return null;
}

/**
 * Sign-in for the admin web app. Same credentials as the mobile app, but
 * the refresh token travels only in an httpOnly, SameSite=Strict cookie
 * scoped to this path, so page scripts can never read it. The access token
 * (15 minutes) is returned in the body and kept in memory by the app.
 */
@ApiTags('admin-auth')
@Controller('admin-auth')
@UseGuards(AdminOriginGuard)
export class AdminAuthController {
  private readonly isProduction: boolean;
  private readonly refreshTtlDays: number;

  constructor(
    private readonly adminAuth: AdminAuthService,
    private readonly audit: AuditService,
    config: ConfigService,
  ) {
    this.isProduction = config.get<AppConfig>('app')!.isProduction;
    this.refreshTtlDays = config.get<JwtConfig>('jwt')!.refreshTtlDays;
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @Throttle(STRICT_THROTTLE)
  @UseGuards(LoginAttemptsGuard)
  @ApiOperation({ summary: 'Admin sign-in (refresh token goes in a cookie)' })
  @ApiOkResponse({ description: '{ data: { user, accessToken } }' })
  @ApiForbiddenResponse({
    type: ApiErrorResponseDto,
    description: 'Correct credentials, but the account is not an admin.',
  })
  async login(
    @Body() dto: LoginDto,
    @ClientContext() ctx: RequestContext,
    @Req() request: Request,
    @Res({ passthrough: true }) response: Response,
  ) {
    const session = await this.adminAuth.login(dto, ctx);
    this.setCookie(response, session.refreshToken);
    void this.audit.record({
      actorUserId: session.user.id,
      action: 'adminAuth.login',
      entityType: 'user',
      entityId: session.user.id,
      method: 'POST',
      path: `${COOKIE_PATH}/login`,
      statusCode: 200,
      ipAddress: request.ip ?? null,
      userAgent: request.headers['user-agent'] ?? null,
    });
    return { data: this.body(session) };
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @Throttle(REFRESH_THROTTLE)
  @ApiOperation({ summary: 'New access token from the refresh cookie' })
  @ApiOkResponse({ description: '{ data: { user, accessToken } }' })
  @ApiUnauthorizedResponse({ type: ApiErrorResponseDto })
  async refresh(
    @ClientContext() ctx: RequestContext,
    @Req() request: Request,
    @Res({ passthrough: true }) response: Response,
  ) {
    const raw = readCookie(request.headers.cookie, ADMIN_REFRESH_COOKIE);
    if (!raw) throw unauthorized('Session expired. Please sign in again.');
    try {
      const session = await this.adminAuth.refresh(raw, ctx);
      this.setCookie(response, session.refreshToken);
      return { data: this.body(session) };
    } catch (error) {
      // The session is over (or never was an admin's): drop the cookie.
      this.clearCookie(response);
      throw error;
    }
  }

  @Post('logout')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiNoContentResponse({ description: 'Session ended, cookie cleared.' })
  async logout(
    @Req() request: Request,
    @Res({ passthrough: true }) response: Response,
  ): Promise<void> {
    const raw = readCookie(request.headers.cookie, ADMIN_REFRESH_COOKIE);
    if (raw) await this.adminAuth.logout(raw);
    this.clearCookie(response);
  }

  private body(session: AdminSession) {
    return {
      user: session.user,
      access: session.access,
      accessToken: session.accessToken,
    };
  }

  private cookieOptions(): CookieOptions {
    return {
      httpOnly: true,
      secure: this.isProduction,
      sameSite: 'strict',
      path: COOKIE_PATH,
    };
  }

  private setCookie(response: Response, refreshToken: string): void {
    response.cookie(ADMIN_REFRESH_COOKIE, refreshToken, {
      ...this.cookieOptions(),
      maxAge: this.refreshTtlDays * 24 * 60 * 60 * 1000,
    });
  }

  private clearCookie(response: Response): void {
    response.clearCookie(ADMIN_REFRESH_COOKIE, this.cookieOptions());
  }
}
