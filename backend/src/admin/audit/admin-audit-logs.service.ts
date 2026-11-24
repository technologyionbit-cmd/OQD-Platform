import { Injectable } from '@nestjs/common';
import type { Prisma } from '@prisma/client';
import { notFound } from '../../common/errors/api-exceptions';
import {
  pageArgs,
  paginated,
  pickSort,
} from '../../common/pagination/page-query.dto';
import { PrismaService } from '../../prisma/prisma.service';
import { AUDIT_SORT_FIELDS, type QueryAuditLogsDto } from './dto/audit-query.dto';

const ACTOR = { select: { id: true, fullName: true, email: true } } as const;

@Injectable()
export class AdminAuditLogsService {
  constructor(private readonly prisma: PrismaService) {}

  async list(query: QueryAuditLogsDto) {
    const where = this.where(query);
    const field = pickSort(query.sort, AUDIT_SORT_FIELDS, 'createdAt');
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.auditLog.findMany({
        where,
        // The list leaves out before/after/meta: they can be large. The
        // detail call returns them.
        select: {
          id: true,
          action: true,
          entityType: true,
          entityId: true,
          method: true,
          path: true,
          statusCode: true,
          ipAddress: true,
          createdAt: true,
          actor: ACTOR,
        },
        orderBy: [{ [field]: query.order }, { id: 'asc' }],
        ...pageArgs(query),
      }),
      this.prisma.auditLog.count({ where }),
    ]);
    return paginated(rows, total, query);
  }

  async detail(id: string) {
    const row = await this.prisma.auditLog.findUnique({
      where: { id },
      include: { actor: ACTOR },
    });
    if (!row) throw notFound('Audit entry not found.');
    return row;
  }

  private where(query: QueryAuditLogsDto): Prisma.AuditLogWhereInput {
    const createdAt: Prisma.DateTimeFilter = {};
    if (query.from) createdAt.gte = new Date(query.from);
    if (query.to) createdAt.lt = new Date(query.to);
    const search = query.q?.trim();

    return {
      ...(query.actorId ? { actorUserId: query.actorId } : {}),
      ...(query.action
        ? { action: { contains: query.action, mode: 'insensitive' } }
        : {}),
      ...(query.entityType ? { entityType: query.entityType } : {}),
      ...(query.entityId ? { entityId: query.entityId } : {}),
      ...(query.outcome === 'success'
        ? { statusCode: { lt: 400 } }
        : query.outcome === 'failure'
          ? { statusCode: { gte: 400 } }
          : {}),
      ...(Object.keys(createdAt).length > 0 ? { createdAt } : {}),
      ...(search
        ? {
            OR: [
              { action: { contains: search, mode: 'insensitive' } },
              { path: { contains: search, mode: 'insensitive' } },
              { entityId: { contains: search } },
              { actor: { fullName: { contains: search, mode: 'insensitive' } } },
            ],
          }
        : {}),
    };
  }
}
