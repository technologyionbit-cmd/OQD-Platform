import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { Request } from 'express';
import { forbidden } from '../../common/errors/api-exceptions';
import type { AppConfig, CorsConfig } from '../../config/configuration';

/** Header the admin app sends on every cookie-using call. */
export const ADMIN_CLIENT_HEADER = 'x-requested-with';
export const ADMIN_CLIENT_VALUE = 'aqd-admin';

/**
 * CSRF defence for the endpoints that read the refresh cookie. SameSite
 * already keeps the cookie off cross-site requests; this adds two checks:
 * a custom header (which a browser only lets through after a CORS
 * preflight that our allow-list answers), and, when the browser sends an
 * Origin, that it is one of CORS_ORIGINS.
 */
@Injectable()
export class AdminOriginGuard implements CanActivate {
  private readonly origins: string[];
  private readonly isProduction: boolean;

  constructor(config: ConfigService) {
    this.origins = config.get<CorsConfig>('cors')!.origins;
    this.isProduction = config.get<AppConfig>('app')!.isProduction;
  }

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<Request>();
    if (request.headers[ADMIN_CLIENT_HEADER] !== ADMIN_CLIENT_VALUE) {
      throw forbidden('Request not allowed from this client.');
    }
    const origin = request.headers.origin;
    // Outside production with no allow-list configured, any origin may
    // call (matches main.ts), so a fresh clone works locally.
    const anyOrigin = !this.isProduction && this.origins.length === 0;
    if (origin && !anyOrigin && !this.origins.includes(origin)) {
      throw forbidden('Request not allowed from this origin.');
    }
    return true;
  }
}
