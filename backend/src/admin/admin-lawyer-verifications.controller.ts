import {
  Body,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  StreamableFile,
} from '@nestjs/common';
import {
  ApiConflictResponse,
  ApiNoContentResponse,
  ApiOperation,
} from '@nestjs/swagger';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ApiErrorResponseDto } from '../common/openapi/api-error.dto';
import { RejectVerificationDto } from '../lawyers/dto/update-my-profile.dto';
import { LawyerVerificationService } from '../lawyers/lawyer-verification.service';
import { AuditAction, AuditNoter } from './audit/audit.decorators';
import type { AuditNoteFn } from './audit/audit.types';
import { AdminController } from './common/admin-controller.decorator';

@AdminController('lawyer-verifications', 'lawyers')
export class AdminLawyerVerificationsController {
  constructor(private readonly verification: LawyerVerificationService) {}

  @Get()
  @ApiOperation({ summary: 'Lawyers waiting for verification, oldest first' })
  async listPending() {
    return { data: await this.verification.listPending() };
  }

  @Get(':lawyerProfileId/documents/:documentId')
  @ApiOperation({ summary: 'Download one submitted document' })
  async document(
    @Param('lawyerProfileId', ParseUUIDPipe) lawyerProfileId: string,
    @Param('documentId', ParseUUIDPipe) documentId: string,
  ): Promise<StreamableFile> {
    const { stream, mimeType } = await this.verification.openDocument(
      lawyerProfileId,
      documentId,
    );
    // Always a download, never rendered inline by a browser.
    return new StreamableFile(stream, {
      type: mimeType,
      disposition: 'attachment',
    });
  }

  @Post(':lawyerProfileId/approve')
  @AuditAction('lawyerVerification.approve')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiNoContentResponse({
    description: 'Verified; the lawyer is notified and becomes bookable.',
  })
  @ApiConflictResponse({
    type: ApiErrorResponseDto,
    description: 'Not pending review.',
  })
  async approve(
    @CurrentUser() admin: AuthenticatedUser,
    @Param('lawyerProfileId', ParseUUIDPipe) lawyerProfileId: string,
    @AuditNoter() note: AuditNoteFn,
  ): Promise<void> {
    note({ entityType: 'lawyerProfile', entityId: lawyerProfileId });
    await this.verification.approve(admin, lawyerProfileId);
  }

  @Post(':lawyerProfileId/reject')
  @AuditAction('lawyerVerification.reject')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiNoContentResponse({
    description: 'Rejected; the lawyer is notified with the reason.',
  })
  @ApiConflictResponse({
    type: ApiErrorResponseDto,
    description: 'Not pending review.',
  })
  async reject(
    @CurrentUser() admin: AuthenticatedUser,
    @Param('lawyerProfileId', ParseUUIDPipe) lawyerProfileId: string,
    @Body() dto: RejectVerificationDto,
    @AuditNoter() note: AuditNoteFn,
  ): Promise<void> {
    note({ entityType: 'lawyerProfile', entityId: lawyerProfileId });
    await this.verification.reject(admin, lawyerProfileId, dto.reason);
  }
}
