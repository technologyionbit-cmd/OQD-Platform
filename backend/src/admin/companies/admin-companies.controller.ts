import {
  Body,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import { ApiConflictResponse, ApiOperation } from '@nestjs/swagger';
import { ApiErrorResponseDto } from '../../common/openapi/api-error.dto';
import { AuditAction, AuditNoter } from '../audit/audit.decorators';
import type { AuditNoteFn } from '../audit/audit.types';
import { AdminController } from '../common/admin-controller.decorator';
import { ReasonDto } from '../users/dto/users.dto';
import { AdminCompaniesService } from './admin-companies.service';
import { QueryAdminCompaniesDto } from './dto/admin-companies.dto';

@AdminController('companies', 'companies')
export class AdminCompaniesController {
  constructor(private readonly companies: AdminCompaniesService) {}

  @Get()
  @ApiOperation({
    summary: 'Search companies: verification state, text; paged and sorted',
  })
  list(@Query() query: QueryAdminCompaniesDto) {
    return this.companies.list(query);
  }

  @Post(':id/verify')
  @HttpCode(HttpStatus.OK)
  @AuditAction('company.verify')
  @ApiConflictResponse({ type: ApiErrorResponseDto })
  @ApiOperation({ summary: 'Mark a company as verified' })
  async verify(
    @Param('id', ParseUUIDPipe) id: string,
    @AuditNoter() note: AuditNoteFn,
  ) {
    const { before, after, company } = await this.companies.decide(
      id,
      'verified',
    );
    note({ entityType: 'organization', entityId: id, before, after });
    return { data: company };
  }

  @Post(':id/reject')
  @HttpCode(HttpStatus.OK)
  @AuditAction('company.reject')
  @ApiConflictResponse({ type: ApiErrorResponseDto })
  @ApiOperation({ summary: 'Reject a company; the reason is kept in the audit log' })
  async reject(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReasonDto,
    @AuditNoter() note: AuditNoteFn,
  ) {
    const { before, after, company } = await this.companies.decide(
      id,
      'rejected',
    );
    note({
      entityType: 'organization',
      entityId: id,
      before,
      after,
      meta: { reason: dto.reason },
    });
    return { data: company };
  }
}
