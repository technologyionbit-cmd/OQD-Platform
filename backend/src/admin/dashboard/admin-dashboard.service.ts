import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export const SERIES_DAYS = 30;
const DAY_MS = 86_400_000;
const RECENT_ACTIVITY = 8;

type Counts<K extends string> = Record<K, number>;

function countsOf<K extends string>(
  keys: readonly K[],
  rows: { key: K; n: number }[],
): Counts<K> {
  const out = Object.fromEntries(keys.map((k) => [k, 0])) as Counts<K>;
  for (const { key, n } of rows) out[key] = n;
  return out;
}

/** UTC date of `date`, as `YYYY-MM-DD`. */
function dayKey(date: Date): string {
  return date.toISOString().slice(0, 10);
}

/**
 * Fills every day of the window, so a quiet day shows as 0 instead of a
 * gap in the chart. Oldest day first.
 */
export function fillSeries(
  rows: { day: Date | string; n: number | bigint }[],
  now: Date,
  days = SERIES_DAYS,
): { date: string; count: number }[] {
  const byDay = new Map<string, number>();
  for (const row of rows) {
    const key = dayKey(new Date(row.day));
    byDay.set(key, (byDay.get(key) ?? 0) + Number(row.n));
  }
  const today = Date.UTC(
    now.getUTCFullYear(),
    now.getUTCMonth(),
    now.getUTCDate(),
  );
  return Array.from({ length: days }, (_, i) => {
    const date = dayKey(new Date(today - (days - 1 - i) * DAY_MS));
    return { date, count: byDay.get(date) ?? 0 };
  });
}

const ROLES = ['client', 'lawyer', 'company', 'admin'] as const;
const VERIFICATION = ['unverified', 'pending', 'verified', 'rejected'] as const;
const CONSULTATION_STATUSES = [
  'pendingApproval',
  'confirmed',
  'completed',
  'cancelled',
  'declined',
  'missed',
  'failed',
] as const;
const CONTRACT_STATUSES = [
  'draft',
  'pendingSignature',
  'signed',
  'completed',
] as const;

const sum = (values: number[]) => values.reduce((a, b) => a + b, 0);

@Injectable()
export class AdminDashboardService {
  constructor(private readonly prisma: PrismaService) {}

  async summary(now = new Date()) {
    const since = new Date(now.getTime() - SERIES_DAYS * DAY_MS);
    const weekAgo = new Date(now.getTime() - 7 * DAY_MS);
    const live = { deletedAt: null };

    const [
      usersByRole,
      suspendedUsers,
      newUsers7d,
      newUsers30d,
      lawyersByVerification,
      orgsPendingVerification,
      organizations,
      consultationsByStatus,
      upcomingConsultations,
      contractsByStatus,
      signupRows,
      consultationRows,
      activity,
    ] = await Promise.all([
      this.prisma.user.groupBy({
        by: ['role'],
        where: live,
        _count: { _all: true },
      }),
      this.prisma.user.count({ where: { ...live, status: 'suspended' } }),
      this.prisma.user.count({
        where: { ...live, createdAt: { gte: weekAgo } },
      }),
      this.prisma.user.count({ where: { ...live, createdAt: { gte: since } } }),
      this.prisma.lawyerProfile.groupBy({
        by: ['verificationStatus'],
        _count: { _all: true },
      }),
      this.prisma.organization.count({
        where: { verificationStatus: 'pending' },
      }),
      this.prisma.organization.count(),
      this.prisma.consultation.groupBy({
        by: ['status'],
        _count: { _all: true },
      }),
      this.prisma.consultation.count({
        where: { status: 'confirmed', scheduledAt: { gte: now } },
      }),
      this.prisma.contract.groupBy({
        by: ['status'],
        _count: { _all: true },
      }),
      this.prisma.$queryRaw<{ day: Date; n: bigint }[]>`
        SELECT date_trunc('day', created_at AT TIME ZONE 'UTC') AS day, count(*) AS n
        FROM users
        WHERE deleted_at IS NULL AND created_at >= ${since}
        GROUP BY 1`,
      this.prisma.$queryRaw<{ day: Date; n: bigint }[]>`
        SELECT date_trunc('day', created_at AT TIME ZONE 'UTC') AS day, count(*) AS n
        FROM consultations
        WHERE created_at >= ${since}
        GROUP BY 1`,
      this.prisma.auditLog.findMany({
        orderBy: { createdAt: 'desc' },
        take: RECENT_ACTIVITY,
        select: {
          id: true,
          action: true,
          entityType: true,
          entityId: true,
          statusCode: true,
          createdAt: true,
          actor: { select: { id: true, fullName: true } },
        },
      }),
    ]);

    const roles = countsOf(
      ROLES,
      usersByRole.map((r) => ({ key: r.role, n: r._count._all })),
    );
    const lawyers = countsOf(
      VERIFICATION,
      lawyersByVerification.map((r) => ({
        key: r.verificationStatus,
        n: r._count._all,
      })),
    );
    const consultations = countsOf(
      CONSULTATION_STATUSES,
      consultationsByStatus.map((r) => ({ key: r.status, n: r._count._all })),
    );
    const contracts = countsOf(
      CONTRACT_STATUSES,
      contractsByStatus.map((r) => ({ key: r.status, n: r._count._all })),
    );

    return {
      generatedAt: now.toISOString(),
      users: {
        total: sum(Object.values(roles)),
        byRole: roles,
        suspended: suspendedUsers,
        newLast7Days: newUsers7d,
        newLast30Days: newUsers30d,
      },
      lawyers: {
        byVerification: lawyers,
        pendingReview: lawyers.pending,
      },
      organizations: {
        total: organizations,
        pendingVerification: orgsPendingVerification,
      },
      consultations: {
        total: sum(Object.values(consultations)),
        byStatus: consultations,
        upcoming: upcomingConsultations,
      },
      contracts: {
        total: sum(Object.values(contracts)),
        byStatus: contracts,
      },
      series: {
        signups: fillSeries(signupRows, now),
        consultations: fillSeries(consultationRows, now),
      },
      recentActivity: activity,
    };
  }
}
