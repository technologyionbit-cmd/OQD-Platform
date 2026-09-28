import { UnprocessableEntityException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHash } from 'node:crypto';
import { PrismaService } from '../../prisma/prisma.service';
import { OtpService } from './otp.service';

interface Row {
  id: string;
  userId: string | null;
  destination: string;
  codeHash: string;
  purpose: string;
  expiresAt: Date;
  consumedAt: Date | null;
  attemptCount: number;
  createdAt: Date;
}

/** Minimal in-memory stand-in for the `verification_codes` table. */
class FakePrisma {
  rows: Row[] = [];
  private seq = 0;

  verificationCode = {
    create: ({ data }: { data: Omit<Row, 'id' | 'consumedAt' | 'attemptCount' | 'createdAt'> }) => {
      const row: Row = {
        id: `vc_${++this.seq}`,
        consumedAt: null,
        attemptCount: 0,
        createdAt: new Date(Date.now() + this.seq),
        ...data,
      };
      this.rows.push(row);
      return Promise.resolve(row);
    },
    findFirst: ({ where }: { where: Record<string, unknown> }) => {
      const match = this.rows
        .filter(
          (r) =>
            r.destination === where.destination &&
            r.purpose === where.purpose &&
            (!('userId' in where) || r.userId === where.userId) &&
            r.consumedAt === null &&
            r.expiresAt.getTime() > Date.now(),
        )
        .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())[0];
      return Promise.resolve(match ?? null);
    },
    findMany: ({
      where,
    }: {
      where: { userId: string; purpose: string; createdAt: { gte: Date } };
    }) =>
      Promise.resolve(
        this.rows
          .filter(
            (r) =>
              r.userId === where.userId &&
              r.purpose === where.purpose &&
              r.createdAt >= where.createdAt.gte,
          )
          .sort((a, b) => a.createdAt.getTime() - b.createdAt.getTime())
          .map((r) => ({ createdAt: r.createdAt })),
      ),
    update: ({
      where,
      data,
    }: {
      where: { id: string };
      data: { attemptCount?: { increment: number }; consumedAt?: Date };
    }) => {
      const row = this.rows.find((r) => r.id === where.id)!;
      if (data.attemptCount) row.attemptCount += data.attemptCount.increment;
      if (data.consumedAt) row.consumedAt = data.consumedAt;
      return Promise.resolve(row);
    },
  };
}

function makeService(fake: FakePrisma): OtpService {
  const config = {
    get: (ns: string) =>
      ns === 'auth'
        ? { otpTtlMinutes: 10, otpMaxAttempts: 3 }
        : { isProduction: false },
  } as unknown as ConfigService;
  return new OtpService(fake as unknown as PrismaService, config);
}

describe('OtpService', () => {
  it('infers the channel from the destination shape', () => {
    const service = makeService(new FakePrisma());
    expect(service.channelFor('user@example.com')).toBe('email');
    expect(service.channelFor('+962790000000')).toBe('sms');
  });

  it('issues a 6-digit code, then verifies and consumes it', async () => {
    const fake = new FakePrisma();
    const service = makeService(fake);

    await service.issue('user@example.com', 'passwordReset', 'u1');
    const code = service.peekDevCode('user@example.com')!;
    expect(code).toMatch(/^\d{6}$/);
    expect(fake.rows[0].codeHash).toBe(
      createHash('sha256').update(code).digest('hex'),
    );

    expect(await service.verify('user@example.com', code, 'passwordReset')).toEqual({
      valid: true,
      userId: 'u1',
    });

    const consumed = await service.consume(
      'user@example.com',
      code,
      'passwordReset',
    );
    expect(consumed.valid).toBe(true);
    expect(fake.rows[0].consumedAt).toBeInstanceOf(Date);

    // consumed — no longer usable
    expect(
      (await service.verify('user@example.com', code, 'passwordReset')).valid,
    ).toBe(false);
  });

  it('locks out after the configured number of failed attempts', async () => {
    const fake = new FakePrisma();
    const service = makeService(fake);
    await service.issue('user@example.com', 'passwordReset', 'u1');

    for (let i = 0; i < 3; i++) {
      expect(
        (await service.verify('user@example.com', '000000', 'passwordReset'))
          .valid,
      ).toBe(false);
    }

    const code = service.peekDevCode('user@example.com')!;
    const locked = await service
      .verify('user@example.com', code, 'passwordReset')
      .catch((e: unknown) => e);
    expect(locked).toBeInstanceOf(UnprocessableEntityException);
    expect((locked as UnprocessableEntityException).getResponse()).toMatchObject(
      { code: 'VERIFICATION_CODE_LOCKED' },
    );
  });

  it('with a userId, ignores a code issued to another account', async () => {
    const fake = new FakePrisma();
    const service = makeService(fake);
    await service.issue('user@example.com', 'emailVerification', 'u1');
    const code = service.peekDevCode('user@example.com')!;

    expect(
      (await service.verify('user@example.com', code, 'emailVerification', 'u2'))
        .valid,
    ).toBe(false);
    expect(
      (await service.consume('user@example.com', code, 'emailVerification', 'u1'))
        .valid,
    ).toBe(true);
  });

  it('lists issue times for an account and purpose, oldest first', async () => {
    const fake = new FakePrisma();
    const service = makeService(fake);
    const since = new Date(Date.now() - 1000);
    await service.issue('a@example.com', 'emailVerification', 'u1');
    await service.issue('a@example.com', 'passwordReset', 'u1');
    await service.issue('a@example.com', 'emailVerification', 'u1');
    await service.issue('b@example.com', 'emailVerification', 'u2');

    const times = await service.issuedSince('u1', 'emailVerification', since);

    expect(times).toHaveLength(2);
    expect(times[0].getTime()).toBeLessThan(times[1].getTime());
  });

  it('treats an expired code as invalid', async () => {
    const fake = new FakePrisma();
    const service = makeService(fake);
    await service.issue('user@example.com', 'passwordReset', 'u1');
    const code = service.peekDevCode('user@example.com')!;
    fake.rows[0].expiresAt = new Date(Date.now() - 1000);

    expect(
      (await service.verify('user@example.com', code, 'passwordReset')).valid,
    ).toBe(false);
  });
});
