import {
  Body,
  Get,
  HttpCode,
  HttpStatus,
  Injectable,
  Post,
  Query,
} from '@nestjs/common';
import { ApiOperation } from '@nestjs/swagger';
import { NotificationType, UserRole } from '@prisma/client';
import type { Prisma } from '@prisma/client';
import { Transform } from 'class-transformer';
import {
  IsBoolean,
  IsEnum,
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
  ValidateIf,
} from 'class-validator';
import {
  PageQueryDto,
  pageArgs,
  paginated,
} from '../../common/pagination/page-query.dto';
import { PrismaService } from '../../prisma/prisma.service';
import { notFound } from '../../common/errors/api-exceptions';
import { AuditAction, AuditNoter } from '../audit/audit.decorators';
import type { AuditNoteFn } from '../audit/audit.types';
import {
  ADMIN_HEAVY_THROTTLE,
  AdminController,
} from '../common/admin-controller.decorator';
import { Throttle } from '@nestjs/throttler';

export class QueryAdminNotificationsDto extends PageQueryDto {
  @IsOptional()
  @IsEnum(NotificationType)
  type?: NotificationType;

  @IsOptional()
  @Transform(({ value }: { value: unknown }) =>
    value === 'true' ? true : value === 'false' ? false : value,
  )
  @IsBoolean()
  read?: boolean;
}

export const AUDIENCES = ['user', 'role', 'all'] as const;
type Audience = (typeof AUDIENCES)[number];
const RECIPIENT_ROLES = [UserRole.client, UserRole.lawyer, UserRole.company];
const BATCH = 1000;

/** A message staff write once, in both app languages. */
export class SendNotificationDto {
  @IsIn(AUDIENCES)
  audience!: Audience;

  @ValidateIf((o: SendNotificationDto) => o.audience === 'user')
  @IsUUID()
  userId?: string;

  @ValidateIf((o: SendNotificationDto) => o.audience === 'role')
  @IsIn(RECIPIENT_ROLES)
  role?: UserRole;

  @IsString() @MinLength(1) @MaxLength(100) titleAr!: string;
  @IsString() @MinLength(1) @MaxLength(100) titleEn!: string;
  @IsString() @MinLength(1) @MaxLength(500) bodyAr!: string;
  @IsString() @MinLength(1) @MaxLength(500) bodyEn!: string;
}

@Injectable()
export class AdminNotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  /** Sends one in-app message to a user, a whole role, or everyone. */
  async send(dto: SendNotificationDto): Promise<{ sent: number }> {
    const ids = await this.recipients(dto);
    const params = {
      titleAr: dto.titleAr.trim(),
      titleEn: dto.titleEn.trim(),
      bodyAr: dto.bodyAr.trim(),
      bodyEn: dto.bodyEn.trim(),
    };
    for (let i = 0; i < ids.length; i += BATCH) {
      await this.prisma.notification.createMany({
        data: ids.slice(i, i + BATCH).map((userId) => ({
          userId,
          type: NotificationType.adminMessage,
          params,
        })),
      });
    }
    return { sent: ids.length };
  }

  private async recipients(dto: SendNotificationDto): Promise<string[]> {
    const live = { deletedAt: null, status: 'active' as const };
    if (dto.audience === 'user') {
      const user = await this.prisma.user.findFirst({
        where: { id: dto.userId, ...live },
        select: { id: true },
      });
      if (!user) throw notFound('That user was not found or is not active.');
      return [user.id];
    }
    const rows = await this.prisma.user.findMany({
      where: {
        ...live,
        role: dto.audience === 'role' ? dto.role : { in: RECIPIENT_ROLES },
      },
      select: { id: true },
    });
    return rows.map((r) => r.id);
  }

  async list(q: QueryAdminNotificationsDto) {
    const search = q.q?.trim();
    const where: Prisma.NotificationWhereInput = {
      ...(q.type && { type: q.type }),
      ...(q.read !== undefined && { readAt: q.read ? { not: null } : null }),
      ...(search && {
        user: {
          OR: [
            { fullName: { contains: search, mode: 'insensitive' } },
            { email: { contains: search, mode: 'insensitive' } },
          ],
        },
      }),
    };
    const [rows, total] = await this.prisma.$transaction([
      this.prisma.notification.findMany({
        where,
        orderBy: [{ createdAt: q.order }, { id: 'asc' }],
        ...pageArgs(q),
        select: {
          id: true,
          type: true,
          readAt: true,
          createdAt: true,
          user: { select: { id: true, fullName: true, email: true } },
        },
      }),
      this.prisma.notification.count({ where }),
    ]);
    return paginated(rows, total, q);
  }
}

/** What the platform sent to users, plus staff messages to them. */
@AdminController('notifications', 'notifications')
export class AdminNotificationsController {
  constructor(private readonly notifications: AdminNotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'Notifications sent: type, read state, recipient' })
  list(@Query() query: QueryAdminNotificationsDto) {
    return this.notifications.list(query);
  }

  @Post('send')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: ADMIN_HEAVY_THROTTLE.default })
  @AuditAction('notification.send')
  @ApiOperation({
    summary: 'Send an in-app message to a user, a role, or everyone',
  })
  async send(@Body() dto: SendNotificationDto, @AuditNoter() note: AuditNoteFn) {
    const result = await this.notifications.send(dto);
    note({
      entityType: 'notification',
      meta: {
        audience: dto.audience,
        userId: dto.userId,
        role: dto.role,
        sent: result.sent,
        titleEn: dto.titleEn,
      },
    });
    return { data: result };
  }
}
