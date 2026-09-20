import { Body, Controller, Param, ParseUUIDPipe, Patch, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ConsultationRoomService } from './consultation-room.service';
import { JoinRoomDto } from './dto/join-room.dto';
import { UpdateRoomMetricsDto } from './dto/update-room-metrics.dto';

@Controller('consultations/:id/room')
@UseGuards(JwtAuthGuard)
export class ConsultationRoomController {
  constructor(private readonly room: ConsultationRoomService) {}

  @Post('token')
  async issueToken(@CurrentUser() user: AuthenticatedUser, @Param('id', ParseUUIDPipe) id: string) {
    const result = await this.room.issueToken(user, id);
    return { data: { roomToken: result.roomToken, expiresAt: result.expiresAt, session: result.session } };
  }

  @Post('join')
  async join(@CurrentUser() user: AuthenticatedUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: JoinRoomDto) {
    return { data: await this.room.join(user, id, dto.roomToken) };
  }

  @Post('connect')
  async connect(@CurrentUser() user: AuthenticatedUser, @Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.room.connect(user, id) };
  }

  @Post('retry')
  async retry(@CurrentUser() user: AuthenticatedUser, @Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.room.retryConnection(user, id) };
  }

  @Post('connection-lost')
  async connectionLost(@CurrentUser() user: AuthenticatedUser, @Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.room.reportConnectionLost(user, id) };
  }

  @Post('leave')
  async leave(@CurrentUser() user: AuthenticatedUser, @Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.room.leave(user, id) };
  }

  @Post('end')
  async end(@CurrentUser() user: AuthenticatedUser, @Param('id', ParseUUIDPipe) id: string) {
    return { data: await this.room.endSession(user, id) };
  }

  @Patch('metrics')
  async updateMetrics(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateRoomMetricsDto,
  ) {
    return { data: await this.room.updateMetrics(user, id, dto) };
  }
}
