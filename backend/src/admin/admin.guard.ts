import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import type { Request } from 'express';
import { forbidden } from '../common/errors/api-exceptions';
import { PrismaService } from '../prisma/prisma.service';
import type { AuthenticatedUser } from '../auth/auth.types';
import {
  ADMIN_MODULE_KEY,
  hasPermission,
  levelFor,
  type AdminModule,
} from './permissions/admin-permissions';

/**
 * Lets only admins through, and only to the modules they were given. Runs
 * after JwtAuthGuard and checks the account in the database, not the
 * token, so removing a role or a permission takes effect at once.
 *
 * A route whose controller names no module is for full-access admins only,
 * so a forgotten declaration fails closed.
 */
@Injectable()
export class AdminGuard implements CanActivate {
  constructor(
    private readonly prisma: PrismaService,
    private readonly reflector: Reflector,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context
      .switchToHttp()
      .getRequest<Request & { user?: AuthenticatedUser }>();
    const userId = request.user?.id;
    const account = userId
      ? await this.prisma.user.findUnique({
          where: { id: userId },
          select: {
            role: true,
            adminFullAccess: true,
            adminPermissions: true,
          },
        })
      : null;
    if (account?.role !== 'admin') {
      throw forbidden('Admins only.');
    }
    if (account.adminFullAccess) return true;

    const module = this.reflector.getAllAndOverride<AdminModule | null>(
      ADMIN_MODULE_KEY,
      [context.getHandler(), context.getClass()],
    );
    const allowed =
      !!module &&
      hasPermission(
        { fullAccess: false, permissions: account.adminPermissions },
        module,
        levelFor(request.method),
      );
    if (!allowed) {
      throw forbidden('Your admin account does not have access to this.');
    }
    return true;
  }
}
