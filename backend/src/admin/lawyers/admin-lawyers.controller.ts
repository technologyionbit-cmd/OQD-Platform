import {
  Body,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Put,
  Query,
} from '@nestjs/common';
import { ApiConflictResponse, ApiOperation } from '@nestjs/swagger';
import type { AuthenticatedUser } from '../../auth/auth.types';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { ApiErrorResponseDto } from '../../common/openapi/api-error.dto';
import { AuditAction, AuditNoter } from '../audit/audit.decorators';
import type { AuditNoteFn } from '../audit/audit.types';
import { AdminController } from '../common/admin-controller.decorator';
import { ReasonDto } from '../users/dto/users.dto';
import { AdminLawyersService } from './admin-lawyers.service';
import {
  QueryAdminLawyersDto,
  UpdateAdminLawyerDto,
} from './dto/admin-lawyers.dto';

/** Lawyer profiles, whatever their verification state, and what staff may fix. */
@AdminController('lawyers', 'lawyers')
export class AdminLawyersController {
  constructor(private readonly lawyers: AdminLawyersService) {}

  @Get()
  @ApiOperation({
    summary: 'Search lawyers: verification state, text; paged and sorted',
  })
  list(@Query() query: QueryAdminLawyersDto) {
    return this.lawyers.list(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'One lawyer: profile, prices and reviews' })
  async detail(@Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.lawyers.detail(id) };
  }

  @Put(':id')
  @HttpCode(HttpStatus.OK)
  @AuditAction('lawyer.update')
  @ApiOperation({ summary: 'Correct a lawyer profile: bio, experience, areas, prices' })
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateAdminLawyerDto,
    @AuditNoter() note: AuditNoteFn,
  ) {
    const { before, after } = await this.lawyers.update(id, dto);
    note({ entityType: 'lawyerProfile', entityId: id, before, after });
    return { data: after };
  }

  @Post(':id/reviews/:reviewId/remove')
  @HttpCode(HttpStatus.NO_CONTENT)
  @AuditAction('lawyer.removeReview')
  @ApiOperation({ summary: 'Delete a review; the rating is recomputed' })
  async removeReview(
    @Param('id', ParseUUIDPipe) id: string,
    @Param('reviewId', ParseUUIDPipe) reviewId: string,
    @Body() dto: ReasonDto,
    @AuditNoter() note: AuditNoteFn,
  ): Promise<void> {
    const removed = await this.lawyers.removeReview(id, reviewId);
    note({
      entityType: 'review',
      entityId: reviewId,
      before: removed,
      meta: { lawyerProfileId: id, reason: dto.reason },
    });
  }

  @Post(':id/revoke-verification')
  @HttpCode(HttpStatus.NO_CONTENT)
  @AuditAction('lawyerVerification.revoke')
  @ApiConflictResponse({ type: ApiErrorResponseDto })
  @ApiOperation({ summary: 'Take verification away; the lawyer is told why' })
  async revoke(
    @CurrentUser() admin: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReasonDto,
    @AuditNoter() note: AuditNoteFn,
  ): Promise<void> {
    const { before, after } = await this.lawyers.revokeVerification(
      admin.id,
      id,
      dto.reason,
    );
    note({
      entityType: 'lawyerProfile',
      entityId: id,
      before,
      after,
      meta: { reason: dto.reason },
    });
  }
}
