import { Get, Param, ParseUUIDPipe, Query } from '@nestjs/common';
import { ApiNotFoundResponse, ApiOperation } from '@nestjs/swagger';
import { ApiErrorResponseDto } from '../../common/openapi/api-error.dto';
import { AdminController } from '../common/admin-controller.decorator';
import { AdminAuditLogsService } from './admin-audit-logs.service';
import { QueryAuditLogsDto } from './dto/audit-query.dto';

/** Read-only: nothing in the API edits or deletes an audit row. */
@AdminController('audit-logs', 'audit')
export class AdminAuditLogsController {
  constructor(private readonly logs: AdminAuditLogsService) {}

  @Get()
  @ApiOperation({ summary: 'Audit trail: who did what, newest first' })
  list(@Query() query: QueryAuditLogsDto) {
    return this.logs.list(query);
  }

  @Get(':id')
  @ApiNotFoundResponse({ type: ApiErrorResponseDto })
  @ApiOperation({ summary: 'One entry with its before/after and request' })
  async detail(@Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.logs.detail(id) };
  }
}
