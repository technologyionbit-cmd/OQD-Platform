import { ForbiddenException, UnauthorizedException } from '@nestjs/common';
import type { AuthService } from '../../auth/auth.service';
import type { TokenService } from '../../auth/services/token.service';
import type { PrismaService } from '../../prisma/prisma.service';
import { readCookie } from './admin-auth.controller';
import { AdminAuthService } from './admin-auth.service';

const ctx = { deviceLabel: null, ipAddress: null };
const tokens = { accessToken: 'a', refreshToken: 'r' };
const adminRow = {
  id: 'u1',
  fullName: 'A',
  email: 'a@a.com',
  phone: '+962791234567',
  role: 'admin',
  status: 'active',
  deletedAt: null,
  phoneVerifiedAt: null,
  adminFullAccess: false,
  adminPermissions: ['users.view'],
};

function setup(opts: { role?: string; account?: object | null } = {}) {
  const revokeByRawToken = jest.fn().mockResolvedValue(undefined);
  const auth = {
    login: jest.fn().mockResolvedValue({
      user: { id: 'u1', role: opts.role ?? 'admin' },
      tokens,
    }),
  };
  const tokenSvc = {
    revokeByRawToken,
    rotate: jest.fn().mockResolvedValue(tokens),
    verifyAccessToken: jest.fn().mockReturnValue({ sub: 'u1' }),
  };
  const prisma = {
    user: {
      findUnique: jest
        .fn()
        .mockResolvedValue(opts.account === undefined ? adminRow : opts.account),
      findUniqueOrThrow: jest.fn().mockResolvedValue(adminRow),
    },
  };
  const svc = new AdminAuthService(
    auth as unknown as AuthService,
    tokenSvc as unknown as TokenService,
    prisma as unknown as PrismaService,
  );
  return { svc, revokeByRawToken };
}

describe('AdminAuthService', () => {
  it('signs an admin in', async () => {
    const { svc, revokeByRawToken } = setup();
    const session = await svc.login(
      { phone: '0791234567', password: 'x' },
      ctx,
    );
    expect(session.accessToken).toBe('a');
    expect(session.access).toEqual({
      fullAccess: false,
      permissions: ['users.view'],
    });
    expect(revokeByRawToken).not.toHaveBeenCalled();
  });

  it('refuses a non-admin with 403 and ends the session it opened', async () => {
    const { svc, revokeByRawToken } = setup({ role: 'client' });
    await expect(
      svc.login({ phone: '0791234567', password: 'x' }, ctx),
    ).rejects.toBeInstanceOf(ForbiddenException);
    expect(revokeByRawToken).toHaveBeenCalledWith('r');
  });

  it('refresh refuses an account that lost the admin role', async () => {
    const { svc, revokeByRawToken } = setup({
      account: { ...adminRow, role: 'client' },
    });
    await expect(svc.refresh('old', ctx)).rejects.toBeInstanceOf(
      ForbiddenException,
    );
    expect(revokeByRawToken).toHaveBeenCalledWith('r');
  });

  it('refresh refuses a suspended account with 401', async () => {
    const { svc } = setup({ account: { ...adminRow, status: 'suspended' } });
    await expect(svc.refresh('old', ctx)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
  });

  it('refresh refuses a soft-deleted account with 401', async () => {
    const { svc } = setup({ account: { ...adminRow, deletedAt: new Date() } });
    await expect(svc.refresh('old', ctx)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
  });
});

describe('readCookie', () => {
  it('finds one cookie among several', () => {
    expect(readCookie('a=1; aqd_admin_rt=tok%2Fx; b=2', 'aqd_admin_rt')).toBe(
      'tok/x',
    );
  });

  it('returns null when absent or malformed', () => {
    expect(readCookie(undefined, 'x')).toBeNull();
    expect(readCookie('a=1', 'x')).toBeNull();
    expect(readCookie('x=%E0%A4%A', 'x')).toBeNull();
  });
});
