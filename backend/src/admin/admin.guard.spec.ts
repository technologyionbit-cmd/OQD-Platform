import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import type { Reflector } from '@nestjs/core';
import type { PrismaService } from '../prisma/prisma.service';
import { AdminGuard } from './admin.guard';
import {
  ALL_PERMISSIONS,
  hasPermission,
  normalizePermissions,
} from './permissions/admin-permissions';

interface Account {
  role: string;
  adminFullAccess?: boolean;
  adminPermissions?: string[];
}

const guardFor = (account: Account | null, module: string | null = 'users') =>
  new AdminGuard(
    {
      user: {
        findUnique: () =>
          Promise.resolve(
            account && {
              adminFullAccess: false,
              adminPermissions: [],
              ...account,
            },
          ),
      },
    } as unknown as PrismaService,
    { getAllAndOverride: () => module } as unknown as Reflector,
  );

const ctx = (user?: { id: string }, method = 'GET') =>
  ({
    switchToHttp: () => ({ getRequest: () => ({ user, method }) }),
    getHandler: () => undefined,
    getClass: () => undefined,
  }) as unknown as ExecutionContext;

describe('AdminGuard', () => {
  it('lets a full-access admin through anywhere', async () => {
    const guard = guardFor({ role: 'admin', adminFullAccess: true }, null);
    await expect(guard.canActivate(ctx({ id: 'u' }, 'POST'))).resolves.toBe(true);
  });

  it.each([['client'], ['lawyer'], ['company']])(
    'answers 403 for role %s',
    async (role) => {
      await expect(
        guardFor({ role, adminFullAccess: true }).canActivate(ctx({ id: 'u' })),
      ).rejects.toBeInstanceOf(ForbiddenException);
    },
  );

  it('answers 403 for a missing account or user', async () => {
    await expect(guardFor(null).canActivate(ctx({ id: 'u' }))).rejects.toBeInstanceOf(
      ForbiddenException,
    );
    await expect(
      guardFor({ role: 'admin', adminFullAccess: true }).canActivate(ctx()),
    ).rejects.toBeInstanceOf(ForbiddenException);
  });

  it('view permission reads but cannot change', async () => {
    const guard = guardFor({ role: 'admin', adminPermissions: ['users.view'] });
    await expect(guard.canActivate(ctx({ id: 'u' }, 'GET'))).resolves.toBe(true);
    await expect(guard.canActivate(ctx({ id: 'u' }, 'POST'))).rejects.toBeInstanceOf(
      ForbiddenException,
    );
  });

  it('manage permission reads and changes', async () => {
    const guard = guardFor({ role: 'admin', adminPermissions: ['users.manage'] });
    await expect(guard.canActivate(ctx({ id: 'u' }, 'GET'))).resolves.toBe(true);
    await expect(guard.canActivate(ctx({ id: 'u' }, 'PUT'))).resolves.toBe(true);
  });

  it('a permission for another module does not help', async () => {
    const guard = guardFor({ role: 'admin', adminPermissions: ['contracts.manage'] });
    await expect(guard.canActivate(ctx({ id: 'u' }, 'GET'))).rejects.toBeInstanceOf(
      ForbiddenException,
    );
  });

  it('a route with no module is for full-access admins only', async () => {
    const limited = guardFor({ role: 'admin', adminPermissions: [...ALL_PERMISSIONS] }, null);
    await expect(limited.canActivate(ctx({ id: 'u' }, 'GET'))).rejects.toBeInstanceOf(
      ForbiddenException,
    );
  });
});

describe('permissions', () => {
  it('manage includes view', () => {
    expect(hasPermission({ fullAccess: false, permissions: ['lawyers.manage'] }, 'lawyers', 'view')).toBe(true);
    expect(hasPermission({ fullAccess: false, permissions: ['lawyers.view'] }, 'lawyers', 'manage')).toBe(false);
  });

  it('normalizing drops unknown values, adds view to manage and keeps order', () => {
    expect(normalizePermissions(['users.manage', 'bogus', 'users.manage', 'audit.manage'])).toEqual([
      'users.view',
      'users.manage',
    ]);
  });

  it('dashboard and audit are view-only', () => {
    expect(ALL_PERMISSIONS).toContain('audit.view');
    expect(ALL_PERMISSIONS).not.toContain('audit.manage');
    expect(ALL_PERMISSIONS).not.toContain('dashboard.manage');
  });
});
