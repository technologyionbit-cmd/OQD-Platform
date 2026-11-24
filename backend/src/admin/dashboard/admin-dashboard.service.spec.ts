import type { PrismaService } from '../../prisma/prisma.service';
import { AdminDashboardService, fillSeries } from './admin-dashboard.service';

describe('fillSeries', () => {
  const now = new Date('2026-11-22T15:00:00Z');

  it('returns one point per day, oldest first, zero for quiet days', () => {
    const series = fillSeries(
      [{ day: new Date('2026-11-21T00:00:00Z'), n: BigInt(3) }],
      now,
      3,
    );
    expect(series).toEqual([
      { date: '2026-11-20', count: 0 },
      { date: '2026-11-21', count: 3 },
      { date: '2026-11-22', count: 0 },
    ]);
  });

  it('ignores rows outside the window', () => {
    const series = fillSeries([{ day: '2020-01-01T00:00:00Z', n: 9 }], now, 2);
    expect(series.every((p) => p.count === 0)).toBe(true);
  });
});

describe('AdminDashboardService.summary', () => {
  it('zero-fills missing groups and totals them', async () => {
    const count = jest.fn().mockResolvedValue(0);
    const prisma = {
      user: {
        groupBy: jest
          .fn()
          .mockResolvedValue([{ role: 'client', _count: { _all: 5 } }]),
        count,
      },
      lawyerProfile: {
        groupBy: jest
          .fn()
          .mockResolvedValue([
            { verificationStatus: 'pending', _count: { _all: 2 } },
          ]),
      },
      organization: { count },
      consultation: { groupBy: jest.fn().mockResolvedValue([]), count },
      contract: { groupBy: jest.fn().mockResolvedValue([]) },
      auditLog: { findMany: jest.fn().mockResolvedValue([]) },
      $queryRaw: jest.fn().mockResolvedValue([]),
    } as unknown as PrismaService;

    const out = await new AdminDashboardService(prisma).summary(
      new Date('2026-11-22T00:00:00Z'),
    );

    expect(out.users.total).toBe(5);
    expect(out.users.byRole).toEqual({
      client: 5,
      lawyer: 0,
      company: 0,
      admin: 0,
    });
    expect(out.lawyers.pendingReview).toBe(2);
    expect(out.consultations.byStatus.confirmed).toBe(0);
    expect(out.series.signups).toHaveLength(30);
  });
});
