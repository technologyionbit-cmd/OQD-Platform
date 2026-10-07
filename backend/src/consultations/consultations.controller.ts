import { Body, Controller, Get, Param, ParseUUIDPipe, Post, UseGuards } from '@nestjs/common';
import { RequireVerifiedEmail } from '../auth/guards/email-verified.guard';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { CancelConsultationDto } from './dto/cancel-consultation.dto';
import { CreateConsultationDto } from './dto/create-consultation.dto';
import { CreateReviewDto } from './dto/create-review.dto';
import { RescheduleConsultationDto } from './dto/reschedule-consultation.dto';
import { ConsultationsService } from './consultations.service';

@Controller('consultations')
@UseGuards(JwtAuthGuard)
export class ConsultationsController {
  constructor(private readonly consultations: ConsultationsService) {}

  @Post()
  @RequireVerifiedEmail()
  async book(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateConsultationDto) {
    return { data: await this.consultations.book(user, dto) };
  }

  @Get()
  async list(@CurrentUser() user: AuthenticatedUser) {
    return { data: await this.consultations.list(user) };
  }

  @Get(':id')
  async getById(@CurrentUser() user: AuthenticatedUser, @Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.consultations.getById(user, id) };
  }

  @Post(':id/accept')
  async accept(@CurrentUser() user: AuthenticatedUser, @Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.consultations.accept(user, id) };
  }

  @Post(':id/decline')
  async decline(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: CancelConsultationDto,
  ) {
    return { data: await this.consultations.decline(user, id, dto.cancellationReason) };
  }

  @Post(':id/cancel')
  async cancel(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: CancelConsultationDto,
  ) {
    return { data: await this.consultations.cancel(user, id, dto.cancellationReason) };
  }

  @Post(':id/reschedule')
  async reschedule(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: RescheduleConsultationDto,
  ) {
    return { data: await this.consultations.reschedule(user, id, dto) };
  }

  @Post(':id/complete')
  async complete(@CurrentUser() user: AuthenticatedUser, @Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.consultations.complete(user, id) };
  }

  @Post(':id/miss')
  async miss(@CurrentUser() user: AuthenticatedUser, @Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.consultations.markMissed(user, id) };
  }

  @Post(':id/fail')
  async fail(@CurrentUser() user: AuthenticatedUser, @Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.consultations.markFailed(user, id) };
  }

  @Post(':id/reviews')
  @RequireVerifiedEmail()
  async review(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: CreateReviewDto,
  ) {
    return { data: await this.consultations.createReview(user, id, dto) };
  }
}
