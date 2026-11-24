import {
  Body,
  Get,
  HttpCode,
  HttpStatus,
  Injectable,
  Param,
  ParseUUIDPipe,
  Post,
  Put,
} from '@nestjs/common';
import { ApiConflictResponse, ApiOperation } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsEmail,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator';
import type { AuthenticatedUser } from '../../auth/auth.types';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { StrongPassword } from '../../auth/dto/password.rules';
import { JordanMobile } from '../../auth/dto/phone.rules';
import { PasswordService } from '../../auth/services/password.service';
import { conflict, notFound } from '../../common/errors/api-exceptions';
import { ApiErrorResponseDto } from '../../common/openapi/api-error.dto';
import { PrismaService } from '../../prisma/prisma.service';
import { AuditAction, AuditNoter } from '../audit/audit.decorators';
import type { AuditNoteFn } from '../audit/audit.types';
import { AdminController } from '../common/admin-controller.decorator';
import { normalizePermissions } from '../permissions/admin-permissions';

const trim = ({ value }: { value: unknown }): unknown =>
  typeof value === 'string' ? value.trim() : value;

export class AdminAccessDto {
  /** Full access: everything, including managing other admins. */
  @IsBoolean()
  fullAccess!: boolean;

  /** `<module>.view` / `<module>.manage`; ignored when [fullAccess]. */
  @IsArray()
  @ArrayMaxSize(40)
  @IsString({ each: true })
  permissions!: string[];
}

export class CreateAdminDto extends AdminAccessDto {
  @Transform(trim)
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  fullName!: string;

  @Transform(trim)
  @IsEmail()
  @MaxLength(254)
  email!: string;

  @JordanMobile()
  phone!: string;

  /** A temporary password the new admin can change after signing in. */
  @StrongPassword()
  password!: string;
}

export class SetAdminPasswordDto {
  @StrongPassword()
  password!: string;
}

const SELECT = {
  id: true,
  fullName: true,
  email: true,
  phone: true,
  status: true,
  adminFullAccess: true,
  adminPermissions: true,
  lastLoginAt: true,
  createdAt: true,
} as const;

type Row = {
  id: string;
  fullName: string;
  email: string;
  phone: string | null;
  status: string;
  adminFullAccess: boolean;
  adminPermissions: string[];
  lastLoginAt: Date | null;
  createdAt: Date;
};

const present = (r: Row) => ({
  id: r.id,
  fullName: r.fullName,
  email: r.email,
  phone: r.phone,
  status: r.status,
  fullAccess: r.adminFullAccess,
  permissions: r.adminPermissions,
  lastLoginAt: r.lastLoginAt,
  createdAt: r.createdAt,
});

@Injectable()
export class AdminAdminsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly passwords: PasswordService,
  ) {}

  async list() {
    const rows = await this.prisma.user.findMany({
      where: { role: 'admin', deletedAt: null },
      select: SELECT,
      orderBy: { createdAt: 'asc' },
    });
    return rows.map(present);
  }

  async create(dto: CreateAdminDto) {
    const taken = await this.prisma.user.findFirst({
      where: { OR: [{ email: dto.email }, { phone: dto.phone }] },
      select: { email: true },
    });
    if (taken) {
      throw conflict('An account with this email or phone already exists.');
    }
    const created = await this.prisma.user.create({
      data: {
        fullName: dto.fullName,
        email: dto.email,
        phone: dto.phone,
        phoneVerifiedAt: new Date(),
        passwordHash: await this.passwords.hash(dto.password),
        role: 'admin',
        adminFullAccess: dto.fullAccess,
        adminPermissions: dto.fullAccess ? [] : normalizePermissions(dto.permissions),
      },
      select: SELECT,
    });
    return present(created);
  }

  async updateAccess(actor: AuthenticatedUser, id: string, dto: AdminAccessDto) {
    const before = await this.target(actor, id);
    if (before.adminFullAccess && !dto.fullAccess) {
      await this.assertAnotherFullAdmin(id);
    }
    const after = await this.prisma.user.update({
      where: { id },
      data: {
        adminFullAccess: dto.fullAccess,
        adminPermissions: dto.fullAccess ? [] : normalizePermissions(dto.permissions),
      },
      select: SELECT,
    });
    // Their current sessions keep working, but the guard reads the new
    // permissions on the very next request.
    return { before: present(before), after: present(after) };
  }

  async setActive(actor: AuthenticatedUser, id: string, active: boolean) {
    const before = await this.target(actor, id);
    if (!active && before.adminFullAccess) {
      await this.assertAnotherFullAdmin(id);
    }
    const after = await this.prisma.$transaction(async (tx) => {
      const updated = await tx.user.update({
        where: { id },
        data: active
          ? {
              status: 'active',
              suspendedAt: null,
              suspendedReason: null,
              suspendedById: null,
            }
          : {
              status: 'suspended',
              suspendedAt: new Date(),
              suspendedReason: 'Admin access removed',
              suspendedById: actor.id,
            },
        select: SELECT,
      });
      if (!active) {
        await tx.refreshToken.updateMany({
          where: { userId: id, revokedAt: null },
          data: { revokedAt: new Date() },
        });
      }
      return updated;
    });
    return { before: present(before), after: present(after) };
  }

  /** Sets a new temporary password and signs the admin out everywhere. */
  async setPassword(actor: AuthenticatedUser, id: string, password: string) {
    const before = await this.target(actor, id);
    const passwordHash = await this.passwords.hash(password);
    await this.prisma.$transaction([
      this.prisma.user.update({ where: { id }, data: { passwordHash } }),
      this.prisma.refreshToken.updateMany({
        where: { userId: id, revokedAt: null },
        data: { revokedAt: new Date() },
      }),
    ]);
    return present(before);
  }

  /** The admin being changed: must exist and must not be the caller. */
  private async target(actor: AuthenticatedUser, id: string): Promise<Row> {
    const row = await this.prisma.user.findFirst({
      where: { id, role: 'admin', deletedAt: null },
      select: SELECT,
    });
    if (!row) throw notFound('Admin not found.');
    if (row.id === actor.id) {
      throw conflict('You cannot change your own access. Ask another admin.');
    }
    return row;
  }

  /** There must always be someone left who can manage admins. */
  private async assertAnotherFullAdmin(excludingId: string): Promise<void> {
    const others = await this.prisma.user.count({
      where: {
        role: 'admin',
        deletedAt: null,
        status: 'active',
        adminFullAccess: true,
        id: { not: excludingId },
      },
    });
    if (others === 0) {
      throw conflict('At least one active full-access admin must remain.');
    }
  }
}

/** Managing admins is for full-access admins only (no module given). */
@AdminController('admins')
export class AdminAdminsController {
  constructor(private readonly admins: AdminAdminsService) {}

  @Get()
  @ApiOperation({ summary: 'Every admin account and what each may do' })
  async list() {
    return { data: await this.admins.list() };
  }

  @Post()
  @AuditAction('admin.create')
  @ApiConflictResponse({ type: ApiErrorResponseDto })
  @ApiOperation({ summary: 'Create an admin account with chosen access' })
  async create(@Body() dto: CreateAdminDto, @AuditNoter() note: AuditNoteFn) {
    const created = await this.admins.create(dto);
    note({ entityType: 'user', entityId: created.id, after: created });
    return { data: created };
  }

  @Put(':id/access')
  @HttpCode(HttpStatus.OK)
  @AuditAction('admin.updateAccess')
  @ApiConflictResponse({ type: ApiErrorResponseDto })
  @ApiOperation({ summary: 'Change what an admin may do' })
  async updateAccess(
    @CurrentUser() actor: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: AdminAccessDto,
    @AuditNoter() note: AuditNoteFn,
  ) {
    const { before, after } = await this.admins.updateAccess(actor, id, dto);
    note({ entityType: 'user', entityId: id, before, after });
    return { data: after };
  }

  @Post(':id/deactivate')
  @HttpCode(HttpStatus.OK)
  @AuditAction('admin.deactivate')
  @ApiConflictResponse({ type: ApiErrorResponseDto })
  @ApiOperation({ summary: 'Switch an admin off and sign them out' })
  async deactivate(
    @CurrentUser() actor: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @AuditNoter() note: AuditNoteFn,
  ) {
    const { before, after } = await this.admins.setActive(actor, id, false);
    note({ entityType: 'user', entityId: id, before, after });
    return { data: after };
  }

  @Post(':id/activate')
  @HttpCode(HttpStatus.OK)
  @AuditAction('admin.activate')
  @ApiOperation({ summary: 'Switch an admin back on' })
  async activate(
    @CurrentUser() actor: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @AuditNoter() note: AuditNoteFn,
  ) {
    const { before, after } = await this.admins.setActive(actor, id, true);
    note({ entityType: 'user', entityId: id, before, after });
    return { data: after };
  }

  @Post(':id/password')
  @HttpCode(HttpStatus.NO_CONTENT)
  @AuditAction('admin.setPassword')
  @ApiOperation({ summary: 'Set a new temporary password; ends their sessions' })
  async setPassword(
    @CurrentUser() actor: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: SetAdminPasswordDto,
    @AuditNoter() note: AuditNoteFn,
  ): Promise<void> {
    const before = await this.admins.setPassword(actor, id, dto.password);
    note({ entityType: 'user', entityId: id, before });
  }
}
