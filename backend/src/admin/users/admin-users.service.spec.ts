import {
  ConflictException,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import type { AuthService } from '../../auth/auth.service';
import type { PrismaService } from '../../prisma/prisma.service';
import { AdminUsersService } from './admin-users.service';
import type { QueryUsersDto } from './dto/users.dto';

const ADMIN = { id: 'admin-1', role: 'admin' as const, sessionId: 's' };
const baseUser = {
  id: 'u1',
  fullName: 'Layla',
  email: 'l@x.com',
  phone: '+962791234567',
  role: 'client',
  status: 'active',
  deletedAt: null,
  suspendedAt: null,
  suspendedReason: null,
  suspendedById: null,
  phoneVerifiedAt: null,
  lastLoginAt: null,
  createdAt: new Date('2026-01-01T00:00:00Z'),
};

function setup(users: Record<string, object> = { u1: baseUser }) {
  const updateMany = jest.fn().mockResolvedValue({ count: 2 });
  const tx: { current: unknown } = { current: null };
  const prisma = {
    user: {
      findUnique: jest.fn(({ where }: { where: { id: string } }) =>
        Promise.resolve(users[where.id] ?? null),
      ),
      update: jest.fn(
        ({ where, data }: { where: { id: string }; data: object }) =>
          Promise.resolve({ ...users[where.id], ...data }),
      ),
      findMany: jest.fn().mockResolvedValue([]),
      count: jest.fn().mockResolvedValue(0),
    },
    refreshToken: { updateMany, findMany: jest.fn() },
    $transaction: jest.fn((arg: unknown): Promise<unknown> =>
      typeof arg === 'function'
        ? (arg as (client: unknown) => Promise<unknown>)(tx.current)
        : Promise.all(arg as Promise<unknown>[]),
    ),
  };
  tx.current = prisma;
  const auth = { forgotPassword: jest.fn().mockResolvedValue(undefined) };
  const service = new AdminUsersService(
    prisma as unknown as PrismaService,
    auth as unknown as AuthService,
  );
  return { service, prisma, auth, updateMany };
}

const query = (over: Partial<QueryUsersDto> = {}): QueryUsersDto =>
  ({ page: 1, limit: 20, order: 'desc', deleted: 'exclude', ...over });

describe('AdminUsersService actions', () => {
  it('suspends: records who and why, and ends every session in the same transaction', async () => {
    const { service, prisma, updateMany } = setup();

    const change = await service.suspend(ADMIN, 'u1', 'abuse');

    expect(prisma.$transaction).toHaveBeenCalledTimes(1);
    expect(prisma.user.update).toHaveBeenCalledWith({
      where: { id: 'u1' },
      data: expect.objectContaining({
        status: 'suspended',
        suspendedReason: 'abuse',
        suspendedById: 'admin-1',
      }) as object,
    });
    expect(updateMany).toHaveBeenCalledWith({
      where: { userId: 'u1', revokedAt: null },
      data: { revokedAt: expect.any(Date) as Date },
    });
    expect(change.before.status).toBe('active');
    expect(change.after.status).toBe('suspended');
  });

  it('refuses to act on yourself or on another admin', async () => {
    const { service } = setup({
      'admin-1': { ...baseUser, id: 'admin-1', role: 'admin' },
      'admin-2': { ...baseUser, id: 'admin-2', role: 'admin' },
    });
    await expect(service.suspend(ADMIN, 'admin-1', 'x y z')).rejects.toBeInstanceOf(ConflictException);
    await expect(service.suspend(ADMIN, 'admin-2', 'x y z')).rejects.toBeInstanceOf(ConflictException);
    await expect(service.softDelete(ADMIN, 'admin-2')).rejects.toBeInstanceOf(ConflictException);
  });

  it('answers 404 for an unknown user', async () => {
    const { service } = setup();
    await expect(service.suspend(ADMIN, 'nope', 'abc')).rejects.toBeInstanceOf(NotFoundException);
  });

  it('cannot suspend twice, or reactivate an active account', async () => {
    const { service } = setup({
      u1: { ...baseUser, status: 'suspended' },
      u2: { ...baseUser, id: 'u2' },
    });
    await expect(service.suspend(ADMIN, 'u1', 'abc')).rejects.toBeInstanceOf(ConflictException);
    await expect(service.activate(ADMIN, 'u2')).rejects.toBeInstanceOf(ConflictException);
  });

  it('reactivation clears the suspension fields', async () => {
    const { service, prisma } = setup({
      u1: { ...baseUser, status: 'suspended', suspendedReason: 'r', suspendedAt: new Date(), suspendedById: 'a' },
    });
    const change = await service.activate(ADMIN, 'u1');
    expect(prisma.user.update).toHaveBeenCalledWith({
      where: { id: 'u1' },
      data: { status: 'active', suspendedAt: null, suspendedReason: null, suspendedById: null },
    });
    expect(change.after.status).toBe('active');
  });

  it('soft delete keeps the row, sets deletedAt and ends sessions; restore undoes it', async () => {
    const { service, prisma, updateMany } = setup();
    const deleted = await service.softDelete(ADMIN, 'u1');
    expect(prisma.user.update).toHaveBeenCalledWith({
      where: { id: 'u1' },
      data: { deletedAt: expect.any(Date) as Date },
    });
    expect(updateMany).toHaveBeenCalled();
    expect(deleted.after.deletedAt).toBeInstanceOf(Date);

    const again = setup({ u1: { ...baseUser, deletedAt: new Date() } });
    await expect(again.service.softDelete(ADMIN, 'u1')).rejects.toBeInstanceOf(ConflictException);
    const restored = await again.service.restore(ADMIN, 'u1');
    expect(restored.after.deletedAt).toBeNull();
    await expect(setup().service.restore(ADMIN, 'u1')).rejects.toBeInstanceOf(ConflictException);
  });

  it('reset password texts the standard code and ends sessions', async () => {
    const { service, auth, updateMany } = setup();
    await service.resetPassword(ADMIN, 'u1');
    expect(auth.forgotPassword).toHaveBeenCalledWith({ phone: '+962791234567' });
    expect(updateMany).toHaveBeenCalled();
  });

  it('reset password needs an active account with a phone', async () => {
    const noPhone = setup({ u1: { ...baseUser, phone: null } });
    await expect(noPhone.service.resetPassword(ADMIN, 'u1')).rejects.toBeInstanceOf(ConflictException);
    const suspended = setup({ u1: { ...baseUser, status: 'suspended' } });
    await expect(suspended.service.resetPassword(ADMIN, 'u1')).rejects.toBeInstanceOf(ConflictException);
    expect(suspended.auth.forgotPassword).not.toHaveBeenCalled();
  });
});

describe('AdminUsersService bulk', () => {
  it('needs a reason to suspend', async () => {
    const { service } = setup();
    await expect(
      service.bulk(ADMIN, { action: 'suspend', ids: ['u1'] }),
    ).rejects.toBeInstanceOf(UnprocessableEntityException);
  });

  it('reports each id: done, or skipped with the reason; ids are de-duplicated', async () => {
    const { service } = setup({
      u1: baseUser,
      u2: { ...baseUser, id: 'u2', role: 'admin' },
      'admin-1': { ...baseUser, id: 'admin-1' },
    });

    const result = await service.bulk(ADMIN, {
      action: 'suspend',
      reason: 'spam',
      ids: ['u1', 'u1', 'u2', 'ghost', 'admin-1'],
    });

    expect(result.succeeded).toEqual(['u1']);
    expect(result.skipped.map((s) => s.id).sort()).toEqual(['admin-1', 'ghost', 'u2']);
    expect(result.skipped.find((s) => s.id === 'u2')?.reason).toMatch(/Admin accounts/);
    expect(result.skipped.find((s) => s.id === 'ghost')?.reason).toMatch(/not found/i);
  });
});

describe('AdminUsersService list/export', () => {
  const firstFindManyArg = (prisma: ReturnType<typeof setup>['prisma']) =>
    (prisma.user.findMany.mock.calls[0] as [Record<string, unknown>])[0];

  it('hides removed accounts by default, shows only them on request', async () => {
    const a = setup();
    await a.service.list(query());
    expect((firstFindManyArg(a.prisma).where as object)).toMatchObject({ deletedAt: null });

    const b = setup();
    await b.service.list(query({ deleted: 'only' }));
    expect((firstFindManyArg(b.prisma).where as object)).toMatchObject({ deletedAt: { not: null } });

    const c = setup();
    await c.service.list(query({ deleted: 'include' }));
    expect(firstFindManyArg(c.prisma).where as object).not.toHaveProperty('deletedAt');
  });

  it('searches phone numbers in any spelling', async () => {
    const { service, prisma } = setup();
    await service.list(query({ q: '0791234567' }));
    const where = firstFindManyArg(prisma).where as { OR: object[] };
    expect(where.OR).toContainEqual({ phone: { contains: '791234567' } });

    const other = setup();
    await other.service.list(query({ q: '+962 79 123 4567' }));
    expect((firstFindManyArg(other.prisma).where as { OR: object[] }).OR).toContainEqual({
      phone: { contains: '791234567' },
    });
  });

  it('filters by role, status and date range, and never selects the password hash', async () => {
    const { service, prisma } = setup();
    await service.list(
      query({ role: 'lawyer', status: 'suspended', createdFrom: '2026-01-01', createdTo: '2026-02-01' }),
    );
    const arg = firstFindManyArg(prisma);
    expect(arg.where).toMatchObject({
      role: 'lawyer',
      status: 'suspended',
      createdAt: { gte: new Date('2026-01-01'), lt: new Date('2026-02-01') },
    });
    expect(JSON.stringify(arg.select)).not.toContain('passwordHash');
  });

  it('only sorts by whitelisted fields', async () => {
    const { service, prisma } = setup();
    await service.list(query({ sort: 'passwordHash' }));
    expect(firstFindManyArg(prisma).orderBy).toEqual([
      { createdAt: 'desc' },
      { id: 'asc' },
    ]);
  });

  it('uses the nulls option only on the nullable lastLoginAt column', async () => {
    // Prisma rejects { sort, nulls } on NOT NULL columns such as createdAt.
    const byLogin = setup();
    await byLogin.service.list(query({ sort: 'lastLoginAt', order: 'asc' }));
    expect(firstFindManyArg(byLogin.prisma).orderBy).toEqual([
      { lastLoginAt: { sort: 'asc', nulls: 'last' } },
      { id: 'asc' },
    ]);

    for (const [sort, expected] of [
      ['fullName', { fullName: 'asc' }],
      ['email', { email: 'asc' }],
      ['createdAt', { createdAt: 'asc' }],
    ] as const) {
      const other = setup();
      await other.service.list(query({ sort, order: 'asc' }));
      expect(firstFindManyArg(other.prisma).orderBy).toEqual([
        expected,
        { id: 'asc' },
      ]);
    }
  });

  it('exports CSV with a BOM and neutralises spreadsheet formulas', async () => {
    const { service, prisma } = setup();
    prisma.user.findMany.mockResolvedValue([
      { ...baseUser, fullName: '=HYPERLINK("http://evil")', email: 'a,b@x.com' },
    ]);
    const { csv, rows } = await service.exportCsv(query());
    expect(rows).toBe(1);
    expect(csv.charCodeAt(0)).toBe(0xfeff);
    expect(csv).toContain(`"'=HYPERLINK(""http://evil"")"`);
    expect(csv).toContain('"a,b@x.com"');
    expect(csv).not.toContain('passwordHash');
  });
});

