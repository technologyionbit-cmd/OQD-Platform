import { Body, Controller, Delete, Get, Param, ParseUUIDPipe, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ConsultationsService } from './consultations.service';
import { CreateAvailabilitySlotDto } from './dto/create-availability-slot.dto';

/**
 * Lives under `/lawyers` (not `/consultations`) to match
 * docs/plans/individual-user-rollout.md Part 4's endpoint table exactly:
 * `GET /v1/lawyers/{id}/availability` (client browse) and the lawyer
 * self-service minimum (`POST`/`DELETE .../lawyers/me/availability`)
 * needed so the client-side booking flow has real slots to book against.
 * `lawyer_schedule_screen.dart` (out of scope, still hits this once the
 * shared consultations datasource is flipped) uses a mock literal lawyer
 * id that isn't a real UUID — that screen breaking against this real
 * endpoint is a known, documented gap, not something fixed here.
 */
@Controller('lawyers')
@UseGuards(JwtAuthGuard)
export class AvailabilityController {
  constructor(private readonly consultations: ConsultationsService) {}

  @Get(':id/availability')
  async getAvailability(@Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.consultations.getAvailability(id) };
  }

  @Post('me/availability')
  async addSlot(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateAvailabilitySlotDto) {
    return { data: await this.consultations.addAvailabilitySlot(user, dto) };
  }

  @Delete('me/availability/:slotId')
  async removeSlot(@CurrentUser() user: AuthenticatedUser, @Param('slotId', ParseUUIDPipe) slotId: string) {
    await this.consultations.removeAvailabilitySlot(user, slotId);
    return { data: null };
  }
}
