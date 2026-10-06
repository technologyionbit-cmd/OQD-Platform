import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import type { Request } from 'express';
import { unauthorized } from '../../common/errors/api-exceptions';
import { TokenService } from '../services/token.service';
import type { AuthenticatedUser } from '../auth.types';

/**
 * Verifies the `Authorization: Bearer <jwt>` access token, checks the
 * session behind it is still live (so "logout everywhere" / password reset
 * take effect at once), and attaches {@link AuthenticatedUser} to
 * `request.user`. Any failure is a 401 with the `UNAUTHORIZED` code —
 * never a different status — so the Flutter `AuthInterceptor`'s
 * refresh-on-401 flow engages correctly (docs §8).
 */
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly tokenService: TokenService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<Request>();
    const header = request.headers.authorization;

    if (!header?.startsWith('Bearer ')) {
      throw unauthorized('Authentication required.');
    }

    const payload = this.tokenService.verifyAccessToken(header.slice(7));

    if (!(await this.tokenService.isSessionActive(payload.sid))) {
      throw unauthorized('Session expired. Please sign in again.');
    }

    const user: AuthenticatedUser = {
      id: payload.sub,
      role: payload.role,
      sessionId: payload.sid,
    };
    (request as Request & { user: AuthenticatedUser }).user = user;
    return true;
  }
}
