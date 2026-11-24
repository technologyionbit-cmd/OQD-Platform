import {
  Body,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  StreamableFile,
} from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiNoContentResponse,
  ApiNotFoundResponse,
  ApiOperation,
} from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import type { AuthenticatedUser } from '../../auth/auth.types';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { ApiErrorResponseDto } from '../../common/openapi/api-error.dto';
import {
  AuditAction,
  AuditNoter,
  AuditRead,
} from '../audit/audit.decorators';
import type { AuditNoteFn } from '../audit/audit.types';
import {
  ADMIN_HEAVY_THROTTLE,
  AdminController,
} from '../common/admin-controller.decorator';
import { AdminUsersService, type Change } from './admin-users.service';
import { BulkUsersDto, QueryUsersDto, ReasonDto } from './dto/users.dto';

@AdminController('users', 'users')
export class AdminUsersController {
  constructor(private readonly users: AdminUsersService) {}

  @Get()
  @ApiOperation({
    summary: 'Search users: role, status, dates, text; paged and sorted',
  })
  list(@Query() query: QueryUsersDto) {
    return this.users.list(query);
  }

  // Declared before `:id` so "export.csv" is not read as an id.
  @Get('export.csv')
  @Throttle(ADMIN_HEAVY_THROTTLE)
  @AuditRead('user.export')
  @ApiOperation({
    summary: 'Download the matching users as CSV (personal data, audited)',
  })
  async export(
    @Query() query: QueryUsersDto,
    @AuditNoter() note: AuditNoteFn,
  ): Promise<StreamableFile> {
    const { csv, rows } = await this.users.exportCsv(query);
    note({ entityType: 'user', meta: { rows, filters: query } });
    return new StreamableFile(Buffer.from(csv, 'utf8'), {
      type: 'text/csv; charset=utf-8',
      disposition: 'attachment; filename="users.csv"',
    });
  }

  @Get(':id')
  @ApiNotFoundResponse({ type: ApiErrorResponseDto })
  @ApiOperation({ summary: 'One user with sessions and related records' })
  async detail(@Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.users.detail(id) };
  }

  @Post('bulk')
  @HttpCode(HttpStatus.OK)
  @Throttle(ADMIN_HEAVY_THROTTLE)
  @AuditAction('user.bulk')
  @ApiOperation({
    summary: 'Suspend, reactivate or sign out many users at once',
    description:
      'Answers which ids succeeded and which were skipped (and why). ' +
      'Admin accounts and the caller are always skipped.',
  })
  async bulk(
    @CurrentUser() admin: AuthenticatedUser,
    @Body() dto: BulkUsersDto,
    @AuditNoter() note: AuditNoteFn,
  ) {
    const result = await this.users.bulk(admin, dto);
    note({
      entityType: 'user',
      meta: {
        action: dto.action,
        succeeded: result.succeeded,
        skipped: result.skipped,
      },
    });
    return { data: result };
  }

  @Post(':id/suspend')
  @HttpCode(HttpStatus.OK)
  @AuditAction('user.suspend')
  @ApiConflictResponse({ type: ApiErrorResponseDto })
  @ApiOperation({ summary: 'Suspend an account and end its sessions' })
  async suspend(
    @CurrentUser() admin: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReasonDto,
    @AuditNoter() note: AuditNoteFn,
  ) {
    return this.respond(
      note,
      id,
      await this.users.suspend(admin, id, dto.reason),
    );
  }

  @Post(':id/activate')
  @HttpCode(HttpStatus.OK)
  @AuditAction('user.activate')
  @ApiConflictResponse({ type: ApiErrorResponseDto })
  @ApiOperation({ summary: 'Reactivate a suspended account' })
  async activate(
    @CurrentUser() admin: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @AuditNoter() note: AuditNoteFn,
  ) {
    return this.respond(note, id, await this.users.activate(admin, id));
  }

  @Post(':id/revoke-sessions')
  @HttpCode(HttpStatus.OK)
  @AuditAction('user.revokeSessions')
  @ApiOperation({ summary: 'Sign the account out of every device' })
  async revokeSessions(
    @CurrentUser() admin: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @AuditNoter() note: AuditNoteFn,
  ) {
    const revoked = await this.users.revokeSessions(admin, id);
    note({ entityType: 'user', entityId: id, meta: { revoked } });
    return { data: { revoked } };
  }

  @Post(':id/reset-password')
  @HttpCode(HttpStatus.NO_CONTENT)
  @Throttle(ADMIN_HEAVY_THROTTLE)
  @AuditAction('user.resetPassword')
  @ApiNoContentResponse({
    description: 'Sessions ended and a reset code texted to the account.',
  })
  @ApiOperation({ summary: 'Send the account a password-reset code' })
  async resetPassword(
    @CurrentUser() admin: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @AuditNoter() note: AuditNoteFn,
  ): Promise<void> {
    note({ entityType: 'user', entityId: id });
    await this.users.resetPassword(admin, id);
  }

  @Post(':id/delete')
  @HttpCode(HttpStatus.OK)
  @AuditAction('user.softDelete')
  @ApiOperation({
    summary: 'Remove an account (soft delete: the row is kept)',
  })
  async softDelete(
    @CurrentUser() admin: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReasonDto,
    @AuditNoter() note: AuditNoteFn,
  ) {
    note({ meta: { reason: dto.reason } });
    return this.respond(note, id, await this.users.softDelete(admin, id));
  }

  @Post(':id/restore')
  @HttpCode(HttpStatus.OK)
  @AuditAction('user.restore')
  @ApiOperation({ summary: 'Bring back a removed account' })
  async restore(
    @CurrentUser() admin: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @AuditNoter() note: AuditNoteFn,
  ) {
    return this.respond(note, id, await this.users.restore(admin, id));
  }

  private respond(note: AuditNoteFn, id: string, change: Change) {
    note({
      entityType: 'user',
      entityId: id,
      before: change.before,
      after: change.after,
    });
    return { data: change.after };
  }
}
