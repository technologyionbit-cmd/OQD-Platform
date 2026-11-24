import { Injectable, Logger } from '@nestjs/common';
import type { Prisma } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { sanitizeForAudit } from './audit-sanitize';

export interface AuditEntry {
  actorUserId: string | null;
  action: string;
  entityType?: string | null;
  entityId?: string | null;
  method: string;
  path: string;
  statusCode: number;
  ipAddress?: string | null;
  userAgent?: string | null;
  before?: unknown;
  after?: unknown;
  meta?: unknown;
}

const asJson = (value: unknown): Prisma.InputJsonValue | undefined => {
  if (value === undefined || value === null) return undefined;
  return sanitizeForAudit(value) as Prisma.InputJsonValue;
};

@Injectable()
export class AuditService {
  private readonly logger = new Logger(AuditService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Appends one audit row. Never throws: the action it describes has
   * already happened, so a logging failure must not turn into an error
   * for the admin. It is logged loudly instead.
   */
  async record(entry: AuditEntry): Promise<void> {
    try {
      await this.prisma.auditLog.create({
        data: {
          actorUserId: entry.actorUserId,
          action: entry.action.slice(0, 120),
          entityType: entry.entityType ?? null,
          entityId: entry.entityId ?? null,
          method: entry.method,
          path: entry.path.slice(0, 500),
          statusCode: entry.statusCode,
          ipAddress: entry.ipAddress ?? null,
          userAgent: entry.userAgent?.slice(0, 255) ?? null,
          before: asJson(entry.before),
          after: asJson(entry.after),
          meta: asJson(entry.meta),
        },
      });
    } catch (error) {
      this.logger.error(
        `Failed to write audit log for ${entry.action}`,
        error instanceof Error ? error.stack : String(error),
      );
    }
  }
}
