import type { ConfigService } from '@nestjs/config';
import type { JwtService } from '@nestjs/jwt';
import { createHash } from 'node:crypto';
import type { PrismaService } from '../../prisma/prisma.service';
import { TokenService } from './token.service';

interface Row {
  id: string;
  userId: string;
  refreshTokenHash: string;
  revokedAt: Date | null;
  expiresAt: Date;
  deviceLabel: string | null;
  ipAddress: string | null;
}

/** In-memory `refresh_tokens` with the conditional-update semantics of SQL. */
class FakePrisma {
  rows: Row[] = [];
  private seq = 0;

  refreshToken = {
    findFirst: async ({ where }: { where: { refreshTokenHash: string } }) => {
      await Promise.resolve();
      const row = this.rows.find(
        (r) => r.refreshTokenHash === where.refreshTokenHash,
      );
      return row
        ? { ...row, user: { role: 'client', status: 'active' } }
        : null;
    },
    // Unconditional update: only here so the pre-fix code can run against
    // this fake and be shown to fail the concurrency test.
    update: async ({
      where,
      data,
    }: {
      where: { id: string };
      data: Partial<Row>;
    }) => {
      await Promise.resolve();
      const row = this.rows.find((r) => r.id === where.id)!;
      Object.assign(row, data);
      return row;
    },
    updateMany: async ({
      where,
      data,
    }: {
      where: { id?: string; userId?: string; revokedAt?: null };
      data: Partial<Row>;
    }) => {
      await Promise.resolve();
      let count = 0;
      for (const r of this.rows) {
        if (where.id !== undefined && r.id !== where.id) continue;
        if (where.userId !== undefined && r.userId !== where.userId) continue;
        if (where.revokedAt === null && r.revokedAt !== null) continue;
        Object.assign(r, data);
        count++;
      }
      return { count };
    },
    create: async ({ data }: { data: Omit<Row, 'id' | 'revokedAt'> }) => {
      await Promise.resolve();
      const row: Row = {
        id: `rt_${++this.seq}`,
        revokedAt: null,
        ...data,
      };
      this.rows.push(row);
      return row;
    },
  };

  $transaction = <T>(fn: (tx: FakePrisma) => Promise<T>) => fn(this);
}

const hash = (raw: string) => createHash('sha256').update(raw).digest('hex');

describe('TokenService.rotate', () => {
  let prisma: FakePrisma;
  let service: TokenService;
  const ctx = { deviceLabel: 'test', ipAddress: '127.0.0.1' };

  beforeEach(() => {
    prisma = new FakePrisma();
    prisma.rows.push({
      id: 'rt_0',
      userId: 'u1',
      refreshTokenHash: hash('raw-token'),
      revokedAt: null,
      expiresAt: new Date(Date.now() + 86_400_000),
      deviceLabel: 'test',
      ipAddress: '127.0.0.1',
    });
    const jwt = { sign: jest.fn(() => 'access.jwt') } as unknown as JwtService;
    const config = {
      get: () => ({ refreshTtlDays: 30 }),
    } as unknown as ConfigService;
    service = new TokenService(prisma as unknown as PrismaService, jwt, config);
  });

  it('rotates a valid token: old revoked, exactly one child created', async () => {
    const tokens = await service.rotate('raw-token', ctx);

    expect(tokens.accessToken).toBe('access.jwt');
    expect(tokens.refreshToken).not.toBe('raw-token');
    expect(prisma.rows).toHaveLength(2);
    expect(prisma.rows[0].revokedAt).not.toBeNull();
    expect(prisma.rows[1].revokedAt).toBeNull();
  });

  it('two concurrent refreshes of one token: one wins, the loser is rejected, the family is revoked', async () => {
    const results = await Promise.allSettled([
      service.rotate('raw-token', ctx),
      service.rotate('raw-token', ctx),
    ]);

    expect(results.filter((r) => r.status === 'fulfilled')).toHaveLength(1);
    expect(results.filter((r) => r.status === 'rejected')).toHaveLength(1);
    // Only the winner's child was ever created (no second child) ...
    expect(prisma.rows).toHaveLength(2);
    // ... and the replay revoked every live session of the user.
    expect(prisma.rows.every((r) => r.revokedAt !== null)).toBe(true);
  });

  it('a replayed (already revoked) token revokes the family and is rejected', async () => {
    await service.rotate('raw-token', ctx);
    await expect(service.rotate('raw-token', ctx)).rejects.toMatchObject({
      status: 401,
    });
    expect(prisma.rows.every((r) => r.revokedAt !== null)).toBe(true);
  });

  it('rejects an unknown token', async () => {
    await expect(service.rotate('nope', ctx)).rejects.toMatchObject({
      status: 401,
    });
  });
});
