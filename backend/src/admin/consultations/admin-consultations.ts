import {
  Body,
  Get,
  HttpCode,
  HttpStatus,
  Injectable,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import { ApiConflictResponse, ApiOperation } from '@nestjs/swagger';
import { ConsultationStatus, ConsultationType } from '@prisma/client';
import type { Prisma } from '@prisma/client';
import { IsDateString, IsEnum, IsOptional } from 'class-validator';
import { conflict, notFound } from '../../common/errors/api-exceptions';
import { ApiErrorResponseDto } from '../../common/openapi/api-error.dto';
import {
  PageQueryDto,
  pageArgs,
  paginated,
  pickSort,
} from '../../common/pagination/page-query.dto';
import { NotificationsService } from '../../notifications/notifications.service';
import { PrismaService } from '../../prisma/prisma.service';
import { AuditAction, AuditNoter } from '../audit/audit.decorators';
import type { AuditNoteFn } from '../audit/audit.types';
import { AdminController } from '../common/admin-controller.decorator';
import { ReasonDto } from '../users/dto/users.dto';

const SORT_FIELDS = ['scheduledAt', 'createdAt', 'price'] as const;

/** Statuses an admin may cancel from, and the one they may complete from. */
const CANCELLABLE: ConsultationStatus[] = ['pendingApproval', 'confirmed'];
const COMPLETABLE: ConsultationStatus[] = ['confirmed'];
/** Shown to the participants as who acted. */
const ADMIN_ACTOR_NAME = 'Aqd';

export class QueryAdminConsultationsDto extends PageQueryDto {
  @IsOptional()
  @IsEnum(ConsultationStatus)
  status?: ConsultationStatus;

  @IsOptional()
  @IsEnum(ConsultationType)
  type?: ConsultationType;

  /** Scheduled on or after this instant (ISO 8601). */
  @IsOptional()
  @IsDateString()
  from?: string;

  /** Scheduled before this instant (ISO 8601). */
  @IsOptional()
  @IsDateString()
  to?: string;
}

@Injectable()
export class AdminConsultationsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
  ) {}

  async list(query: QueryAdminConsultationsDto) {
    const where = this.where(query);
    const field = pickSort(query.sort, SORT_FIELDS, 'scheduledAt');
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.consultation.findMany({
        where,
        orderBy: [{ [field]: query.order }, { id: 'asc' }],
        ...pageArgs(query),
        select: {
          id: true,
          clientName: true,
          lawyerName: true,
          type: true,
          status: true,
          scheduledAt: true,
          price: true,
          cancellationReason: true,
          createdAt: true,
        },
      }),
      this.prisma.consultation.count({ where }),
    ]);
    return paginated(
      rows.map((r) => ({ ...r, price: Number(r.price) })),
      total,
      query,
    );
  }

  async detail(id: string) {
    const row = await this.prisma.consultation.findUnique({
      where: { id },
      include: {
        client: { select: { id: true, email: true, phone: true } },
        lawyerProfile: {
          select: { id: true, user: { select: { email: true, phone: true } } },
        },
        roomSession: {
          include: { events: { orderBy: { createdAt: 'asc' } } },
        },
      },
    });
    if (!row) throw notFound('Consultation not found.');
    return {
      id: row.id,
      type: row.type,
      status: row.status,
      scheduledAt: row.scheduledAt,
      price: Number(row.price),
      notes: row.notes,
      cancellationReason: row.cancellationReason,
      createdAt: row.createdAt,
      client: { name: row.clientName, ...row.client },
      lawyer: {
        name: row.lawyerName,
        profileId: row.lawyerProfile.id,
        email: row.lawyerProfile.user.email,
        phone: row.lawyerProfile.user.phone,
      },
      room: row.roomSession && {
        state: row.roomSession.state,
        endedAt: row.roomSession.endedAt,
        reconnectAttempts: row.roomSession.reconnectAttempts,
        events: row.roomSession.events.map((e) => ({
          userId: e.userId,
          type: e.eventType,
          at: e.createdAt,
        })),
      },
      canCancel: CANCELLABLE.includes(row.status),
      canComplete: COMPLETABLE.includes(row.status),
    };
  }

  /** Cancels, frees the lawyer's slot and tells both people. */
  async cancel(id: string, reason: string) {
    return this.move(id, 'cancelled', CANCELLABLE, 'consultationCancelled', {
      cancellationReason: reason,
    });
  }

  /** Closes a consultation stuck at `confirmed` as completed. */
  async complete(id: string) {
    return this.move(id, 'completed', COMPLETABLE, 'consultationCompleted');
  }

  private async move(
    id: string,
    to: ConsultationStatus,
    from: ConsultationStatus[],
    notification: 'consultationCancelled' | 'consultationCompleted',
    data: Prisma.ConsultationUpdateManyMutationInput = {},
  ) {
    const current = await this.prisma.consultation.findUnique({
      where: { id },
      include: { lawyerProfile: { select: { userId: true } } },
    });
    if (!current) throw notFound('Consultation not found.');
    if (!from.includes(current.status)) {
      throw conflict(`A ${current.status} consultation cannot become ${to}.`);
    }

    await this.prisma.$transaction(async (tx) => {
      // Only if nobody changed it since we read it.
      const moved = await tx.consultation.updateMany({
        where: { id, status: current.status },
        data: { ...data, status: to },
      });
      if (moved.count === 0) {
        throw conflict('This consultation was just changed. Refresh.');
      }
      if (to === 'cancelled') {
        await tx.availabilitySlot.update({
          where: { id: current.availabilitySlotId },
          data: { isBooked: false },
        });
      }
      for (const userId of [current.clientUserId, current.lawyerProfile.userId]) {
        await this.notifications.notify(tx, {
          userId,
          type: notification,
          relatedId: id,
          params: {
            actorName: ADMIN_ACTOR_NAME,
            scheduledAt: current.scheduledAt.toISOString(),
          },
        });
      }
    });
    return {
      before: { status: current.status },
      after: { status: to, ...data },
    };
  }

  private where(q: QueryAdminConsultationsDto): Prisma.ConsultationWhereInput {
    const scheduledAt: Prisma.DateTimeFilter = {};
    if (q.from) scheduledAt.gte = new Date(q.from);
    if (q.to) scheduledAt.lt = new Date(q.to);
    const search = q.q?.trim();
    return {
      ...(q.status && { status: q.status }),
      ...(q.type && { type: q.type }),
      ...((q.from || q.to) && { scheduledAt }),
      ...(search && {
        OR: [
          { clientName: { contains: search, mode: 'insensitive' } },
          { lawyerName: { contains: search, mode: 'insensitive' } },
        ],
      }),
    };
  }
}

@AdminController('consultations', 'consultations')
export class AdminConsultationsController {
  constructor(private readonly consultations: AdminConsultationsService) {}

  @Get()
  @ApiOperation({ summary: 'Search consultations: status, type, dates, names' })
  list(@Query() query: QueryAdminConsultationsDto) {
    return this.consultations.list(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'One consultation with the room session history' })
  async detail(@Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.consultations.detail(id) };
  }

  @Post(':id/cancel')
  @HttpCode(HttpStatus.NO_CONTENT)
  @AuditAction('consultation.cancel')
  @ApiConflictResponse({ type: ApiErrorResponseDto })
  @ApiOperation({ summary: 'Cancel a booking; both people are notified' })
  async cancel(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReasonDto,
    @AuditNoter() note: AuditNoteFn,
  ): Promise<void> {
    const { before, after } = await this.consultations.cancel(id, dto.reason);
    note({ entityType: 'consultation', entityId: id, before, after });
  }

  @Post(':id/complete')
  @HttpCode(HttpStatus.NO_CONTENT)
  @AuditAction('consultation.complete')
  @ApiConflictResponse({ type: ApiErrorResponseDto })
  @ApiOperation({ summary: 'Mark a confirmed consultation as completed' })
  async complete(
    @Param('id', ParseUUIDPipe) id: string,
    @AuditNoter() note: AuditNoteFn,
  ): Promise<void> {
    const { before, after } = await this.consultations.complete(id);
    note({ entityType: 'consultation', entityId: id, before, after });
  }
}
