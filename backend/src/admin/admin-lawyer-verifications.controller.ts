import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  StreamableFile,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiConflictResponse,
  ApiForbiddenResponse,
  ApiNoContentResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiErrorResponseDto } from '../common/openapi/api-error.dto';
import { BEARER_AUTH } from '../common/openapi/setup-openapi';
import { RejectVerificationDto } from '../lawyers/dto/update-my-profile.dto';
import { LawyerVerificationService } from '../lawyers/lawyer-verification.service';
import { AdminGuard } from './admin.guard';

@ApiTags('admin')
@ApiBearerAuth(BEARER_AUTH)
@ApiForbiddenResponse({
  type: ApiErrorResponseDto,
  description: 'The caller is not an admin.',
})
@Controller('admin/lawyer-verifications')
@UseGuards(JwtAuthGuard, AdminGuard)
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
  ): Promise<void> {
    await this.verification.approve(admin, lawyerProfileId);
  }

  @Post(':lawyerProfileId/reject')
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
  ): Promise<void> {
    await this.verification.reject(admin, lawyerProfileId, dto.reason);
  }
}
