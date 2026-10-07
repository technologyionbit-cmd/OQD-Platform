import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiConsumes, ApiOperation, ApiTags } from '@nestjs/swagger';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { BEARER_AUTH } from '../common/openapi/setup-openapi';
import { QueryLawyersDto } from './dto/query-lawyers.dto';
import { QueryReviewsDto } from './dto/query-reviews.dto';
import { UpdateMyProfileDto } from './dto/update-my-profile.dto';
import {
  LawyerVerificationService,
  type UploadedVerificationFile,
} from './lawyer-verification.service';
import { LawyersService } from './lawyers.service';
import { VERIFICATION_MAX_FILE_BYTES, VERIFICATION_MAX_FILES } from './verification-files';

/**
 * Marketplace search/browse (verified lawyers only), plus the signed-in
 * lawyer's own profile and verification submission under /v1/lawyers/me.
 * Admins review submissions under /v1/admin.
 */
@ApiTags('lawyers')
@ApiBearerAuth(BEARER_AUTH)
@Controller('lawyers')
@UseGuards(JwtAuthGuard)
export class LawyersController {
  constructor(
    private readonly lawyers: LawyersService,
    private readonly verification: LawyerVerificationService,
  ) {}

  @Get()
  findAll(@Query() query: QueryLawyersDto) {
    return this.lawyers.findAll(query);
  }

  // The "me" routes are declared before ':id' so "me" is never parsed as an id.
  @Get('me')
  findMine(@CurrentUser() user: AuthenticatedUser) {
    return this.lawyers.findMine(user).then((data) => ({ data }));
  }

  @Patch('me')
  @ApiOperation({ summary: "Update the signed-in lawyer's profile and prices" })
  updateMine(@CurrentUser() user: AuthenticatedUser, @Body() dto: UpdateMyProfileDto) {
    return this.lawyers.updateMine(user, dto).then((data) => ({ data }));
  }

  @Post('me/verification')
  @ApiConsumes('multipart/form-data')
  @ApiOperation({
    summary: 'Send verification documents',
    description:
      `Multipart field "documents": 1-${VERIFICATION_MAX_FILES} JPEG, PNG or PDF files, ` +
      'at most 10 MB each. Moves the profile to pending review (409 if it ' +
      'is already pending or verified).',
  })
  @UseInterceptors(
    FilesInterceptor('documents', VERIFICATION_MAX_FILES, {
      limits: { fileSize: VERIFICATION_MAX_FILE_BYTES, files: VERIFICATION_MAX_FILES },
    }),
  )
  submitVerification(
    @CurrentUser() user: AuthenticatedUser,
    @UploadedFiles() files: UploadedVerificationFile[] | undefined,
  ) {
    return this.verification.submit(user, files ?? []).then((data) => ({ data }));
  }

  @Get(':id')
  findById(@Param('id', ParseUUIDPipe) id: string) {
    return this.lawyers.findById(id).then((data) => ({ data }));
  }

  @Get(':id/reviews')
  findReviews(@Param('id', ParseUUIDPipe) id: string, @Query() query: QueryReviewsDto) {
    return this.lawyers.findReviews(id, query);
  }
}
