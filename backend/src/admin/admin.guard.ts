import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import type { Request } from 'express';
import { forbidden } from '../common/errors/api-exceptions';
import { PrismaService } from '../prisma/prisma.service';
import type { AuthenticatedUser } from '../auth/auth.types';

/**
 * Lets only admins through. Runs after JwtAuthGuard and checks the role in
 * the database, not the one in the token, so removing someone's admin
 * role takes effect at once instead of when their token expires.
 */
@Injectable()
export class AdminGuard implements CanActivate {
  constructor(private readonly prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context
      .switchToHttp()
      .getRequest<Request & { user?: AuthenticatedUser }>();
    const userId = request.user?.id;
    const account = userId
      ? await this.prisma.user.findUnique({
          where: { id: userId },
          select: { role: true },
        })
      : null;
    if (account?.role !== 'admin') {
      throw forbidden('Admins only.');
    }
    return true;
  }
}
