import { Injectable } from '@nestjs/common';
import type { Notification, NotificationType, Prisma } from '@prisma/client';
import { notFound } from '../common/errors/api-exceptions';
import { PrismaService } from '../prisma/prisma.service';

/** The newest notifications a list returns; older ones stay stored. */
export const NOTIFICATIONS_PAGE_SIZE = 100;

export interface NotifyInput {
  /** The account that receives it. */
  userId: string;
  type: NotificationType;
  relatedId?: string;
  params?: Record<string, string>;
}

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Records a notification. Callers pass their transaction client so the
   * notification exists only if the change it reports was saved.
   */
  async notify(
    tx: Prisma.TransactionClient,
    input: NotifyInput,
  ): Promise<void> {
    await tx.notification.create({
      data: {
        userId: input.userId,
        type: input.type,
        relatedId: input.relatedId,
        params: input.params ?? {},
      },
    });
  }

  async list(userId: string) {
    const [rows, unreadCount] = await this.prisma.$transaction([
      this.prisma.notification.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        take: NOTIFICATIONS_PAGE_SIZE,
      }),
      this.prisma.notification.count({ where: { userId, readAt: null } }),
    ]);
    return { data: rows.map((row) => this.toView(row)), meta: { unreadCount } };
  }

  async markRead(userId: string, id: string): Promise<void> {
    const updated = await this.prisma.notification.updateMany({
      where: { id, userId },
      data: { readAt: new Date() },
    });
    if (updated.count === 0) throw notFound('Notification not found.');
  }

  async markAllRead(userId: string): Promise<void> {
    await this.prisma.notification.updateMany({
      where: { userId, readAt: null },
      data: { readAt: new Date() },
    });
  }

  async remove(userId: string, id: string): Promise<void> {
    const deleted = await this.prisma.notification.deleteMany({
      where: { id, userId },
    });
    if (deleted.count === 0) throw notFound('Notification not found.');
  }

  private toView(row: Notification) {
    return {
      id: row.id,
      type: row.type,
      relatedId: row.relatedId,
      params: row.params,
      isRead: row.readAt !== null,
      createdAt: row.createdAt,
    };
  }
}
