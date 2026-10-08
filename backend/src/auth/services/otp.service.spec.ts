import { UnprocessableEntityException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHash } from 'node:crypto';
import { PrismaService } from '../../prisma/prisma.service';
import { sendNgtSms } from './ngt-sms.client';
import { OtpService, smsText } from './otp.service';

jest.mock('./ngt-sms.client', () => ({
  sendNgtSms: jest.fn(() => Promise.resolve({ ok: true, code: 'I01' })),
}));

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
      where: {
        userId?: string;
        destination?: string;
        purpose: string;
        createdAt: { gte: Date };
      };
    }) =>
      Promise.resolve(
        this.rows
          .filter(
            (r) =>
              (!('userId' in where) || r.userId === where.userId) &&
              (!('destination' in where) ||
                r.destination === where.destination) &&
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
      data: RowUpdate;
    }) => {
      const row = this.rows.find((r) => r.id === where.id)!;
      applyUpdate(row, data);
      return Promise.resolve(row);
    },
    updateMany: ({
      where,
      data,
    }: {
      where: {
        id: string;
        attemptCount?: { lt: number };
        consumedAt?: null;
      };
      data: RowUpdate;
    }) => {
      const matching = this.rows.filter(
        (r) =>
          r.id === where.id &&
          (!where.attemptCount || r.attemptCount < where.attemptCount.lt) &&
          (!('consumedAt' in where) || r.consumedAt === null),
      );
      matching.forEach((row) => applyUpdate(row, data));
      return Promise.resolve({ count: matching.length });
    },
  };
}

interface RowUpdate {
  attemptCount?: { increment: number } | { decrement: number };
  consumedAt?: Date;
}

function applyUpdate(row: Row, data: RowUpdate): void {
  if (data.attemptCount && 'increment' in data.attemptCount) {
    row.attemptCount += data.attemptCount.increment;
  }
  if (data.attemptCount && 'decrement' in data.attemptCount) {
    row.attemptCount -= data.attemptCount.decrement;
  }
  if (data.consumedAt) row.consumedAt = data.consumedAt;
}

const SMS = {
  baseUrl: 'https://sms.test/send',
  loginName: 'aqd',
  loginPassword: 'secret',
  senderId: 'Aqd',
};

function makeService(
  fake: FakePrisma,
  { sms, isProduction = false }: { sms?: typeof SMS; isProduction?: boolean } = {},
): OtpService {
  const config = {
    get: (ns: string) =>
      ({
        auth: { otpTtlMinutes: 10, otpMaxAttempts: 3 },
        app: { isProduction },
        sms,
      })[ns],
  } as unknown as ConfigService;
  return new OtpService(fake as unknown as PrismaService, config);
}

const PHONE = '+962791234567';
const OTHER_PHONE = '+962781234567';
const UNKNOWN_PHONE = '+962771234567';

describe('OtpService', () => {
  beforeEach(() => jest.mocked(sendNgtSms).mockClear());

  it('texts the code through the gateway when it is configured', async () => {
    const service = makeService(new FakePrisma(), { sms: SMS });
    await service.issue(PHONE, 'phoneVerification', 'u1');
    const code = service.peekDevCode(PHONE)!;

    await new Promise((resolve) => setImmediate(resolve));
    expect(sendNgtSms).toHaveBeenCalledWith(SMS, PHONE, smsText(code));
  });

  it('never texts a number that has no account', async () => {
    const service = makeService(new FakePrisma(), { sms: SMS });
    await service.issue(UNKNOWN_PHONE, 'passwordReset', null);

    await new Promise((resolve) => setImmediate(resolve));
    expect(sendNgtSms).not.toHaveBeenCalled();
  });

  it('does not fail the request when the gateway fails', async () => {
    jest.mocked(sendNgtSms).mockRejectedValueOnce(new Error('timeout'));
    const service = makeService(new FakePrisma(), { sms: SMS });

    await expect(
      service.issue(PHONE, 'phoneVerification', 'u1'),
    ).resolves.toBeUndefined();
  });

  it('keeps no readable code in production', async () => {
    const service = makeService(new FakePrisma(), { sms: SMS, isProduction: true });
    await service.issue(PHONE, 'phoneVerification', 'u1');

    expect(service.peekDevCode(PHONE)).toBeUndefined();
  });

  it('fits the message in one SMS segment', () => {
    expect(smsText('123456').length).toBeLessThanOrEqual(70);
    expect(smsText('123456')).toContain('123456');
  });

  it('issues a 6-digit code, then verifies and consumes it', async () => {
    const fake = new FakePrisma();
    const service = makeService(fake);

    await service.issue(PHONE, 'passwordReset', 'u1');
    const code = service.peekDevCode(PHONE)!;
    expect(code).toMatch(/^\d{6}$/);
    expect(fake.rows[0].codeHash).toBe(
      createHash('sha256').update(code).digest('hex'),
    );

    expect(await service.verify(PHONE, code, 'passwordReset')).toEqual({
      valid: true,
      userId: 'u1',
    });

    const consumed = await service.consume(
      PHONE,
      code,
      'passwordReset',
    );
    expect(consumed.valid).toBe(true);
    expect(fake.rows[0].consumedAt).toBeInstanceOf(Date);

    // consumed — no longer usable
    expect(
      (await service.verify(PHONE, code, 'passwordReset')).valid,
    ).toBe(false);
  });

  it('locks out after the configured number of failed attempts', async () => {
    const fake = new FakePrisma();
    const service = makeService(fake);
    await service.issue(PHONE, 'passwordReset', 'u1');

    for (let i = 0; i < 3; i++) {
      expect(
        (await service.verify(PHONE, '000000', 'passwordReset'))
          .valid,
      ).toBe(false);
    }

    const code = service.peekDevCode(PHONE)!;
    const locked = await service
      .verify(PHONE, code, 'passwordReset')
      .catch((e: unknown) => e);
    expect(locked).toBeInstanceOf(UnprocessableEntityException);
    expect((locked as UnprocessableEntityException).getResponse()).toMatchObject(
      { code: 'VERIFICATION_CODE_LOCKED' },
    );
  });

  it('with a userId, ignores a code issued to another account', async () => {
    const fake = new FakePrisma();
    const service = makeService(fake);
    await service.issue(PHONE, 'phoneVerification', 'u1');
    const code = service.peekDevCode(PHONE)!;

    expect(
      (await service.verify(PHONE, code, 'phoneVerification', 'u2'))
        .valid,
    ).toBe(false);
    expect(
      (await service.consume(PHONE, code, 'phoneVerification', 'u1'))
        .valid,
    ).toBe(true);
  });

  it('lists issue times for an account and purpose, oldest first', async () => {
    const fake = new FakePrisma();
    const service = makeService(fake);
    const since = new Date(Date.now() - 1000);
    await service.issue(PHONE, 'phoneVerification', 'u1');
    await service.issue(PHONE, 'passwordReset', 'u1');
    await service.issue(PHONE, 'phoneVerification', 'u1');
    await service.issue(OTHER_PHONE, 'phoneVerification', 'u2');

    const times = await service.issuedSince(
      { userId: 'u1' },
      'phoneVerification',
      since,
    );

    expect(times).toHaveLength(2);
    expect(times[0].getTime()).toBeLessThan(times[1].getTime());
  });

  it('lists issue times for a number, with or without an account', async () => {
    const fake = new FakePrisma();
    const service = makeService(fake);
    const since = new Date(Date.now() - 1000);
    await service.issue(UNKNOWN_PHONE, 'passwordReset', null);
    await service.issue(UNKNOWN_PHONE, 'passwordReset', null);
    await service.issue(PHONE, 'passwordReset', 'u1');

    const times = await service.issuedSince(
      { destination: UNKNOWN_PHONE },
      'passwordReset',
      since,
    );

    expect(times).toHaveLength(2);
  });

  it('does not count a right code as a try', async () => {
    const fake = new FakePrisma();
    const service = makeService(fake);
    await service.issue(PHONE, 'passwordReset', 'u1');
    const code = service.peekDevCode(PHONE)!;

    // Two wrong tries, then the code screen and the reset step both check
    // the right code — with 3 tries allowed, none of that locks it.
    await service.verify(PHONE, '000000', 'passwordReset');
    await service.verify(PHONE, '000001', 'passwordReset');
    expect(
      (await service.verify(PHONE, code, 'passwordReset')).valid,
    ).toBe(true);
    expect(
      (await service.consume(PHONE, code, 'passwordReset')).valid,
    ).toBe(true);
    expect(fake.rows[0].attemptCount).toBe(2);
  });

  it('lets only one of two parallel requests consume a code', async () => {
    const fake = new FakePrisma();
    const service = makeService(fake);
    await service.issue(PHONE, 'passwordReset', 'u1');
    const code = service.peekDevCode(PHONE)!;

    const results = await Promise.all([
      service.consume(PHONE, code, 'passwordReset'),
      service.consume(PHONE, code, 'passwordReset'),
    ]);

    expect(results.filter((r) => r.valid)).toHaveLength(1);
  });

  it('never gives parallel guesses more than the allowed tries', async () => {
    const fake = new FakePrisma();
    const service = makeService(fake);
    await service.issue(PHONE, 'passwordReset', 'u1');
    const code = Number(service.peekDevCode(PHONE));
    const wrong = (i: number) =>
      String((code + 1 + i) % 1_000_000).padStart(6, '0');

    const outcomes = await Promise.allSettled(
      Array.from({ length: 10 }, (_, i) =>
        service.verify(PHONE, wrong(i), 'passwordReset'),
      ),
    );

    expect(outcomes.filter((o) => o.status === 'fulfilled')).toHaveLength(3);
    expect(fake.rows[0].attemptCount).toBe(3);
  });

  it('treats an expired code as invalid', async () => {
    const fake = new FakePrisma();
    const service = makeService(fake);
    await service.issue(PHONE, 'passwordReset', 'u1');
    const code = service.peekDevCode(PHONE)!;
    fake.rows[0].expiresAt = new Date(Date.now() - 1000);

    expect(
      (await service.verify(PHONE, code, 'passwordReset')).valid,
    ).toBe(false);
  });
});
