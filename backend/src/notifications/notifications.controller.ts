import {
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiNoContentResponse,
  ApiNotFoundResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiErrorResponseDto } from '../common/openapi/api-error.dto';
import { BEARER_AUTH } from '../common/openapi/setup-openapi';
import {
  NOTIFICATIONS_PAGE_SIZE,
  NotificationsService,
} from './notifications.service';

@ApiTags('notifications')
@ApiBearerAuth(BEARER_AUTH)
@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(private readonly notifications: NotificationsService) {}

  @Get()
  @ApiOperation({
    summary: "The caller's notifications, newest first",
    description:
      `At most ${NOTIFICATIONS_PAGE_SIZE}. \`meta.unreadCount\` counts all ` +
      'unread ones. The app builds the text from `type` and `params`.',
  })
  list(@CurrentUser() user: AuthenticatedUser) {
    return this.notifications.list(user.id);
  }

  // Declared before ':id/read' so "read-all" is never taken for an id.
  @Post('read-all')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiNoContentResponse({ description: 'Every notification is marked read.' })
  async markAllRead(@CurrentUser() user: AuthenticatedUser): Promise<void> {
    await this.notifications.markAllRead(user.id);
  }

  @Post(':id/read')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiNoContentResponse({ description: 'Marked read (idempotent).' })
  @ApiNotFoundResponse({
    type: ApiErrorResponseDto,
    description: 'No such notification, or not yours.',
  })
  async markRead(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<void> {
    await this.notifications.markRead(user.id, id);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiNoContentResponse({ description: 'Deleted.' })
  @ApiNotFoundResponse({
    type: ApiErrorResponseDto,
    description: 'No such notification, or not yours.',
  })
  async remove(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<void> {
    await this.notifications.remove(user.id, id);
  }
}
