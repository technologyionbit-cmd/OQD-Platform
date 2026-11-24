import { Get } from '@nestjs/common';
import { ApiOperation } from '@nestjs/swagger';
import { AdminController } from '../common/admin-controller.decorator';
import { AdminDashboardService } from './admin-dashboard.service';

/** Read-only overview for the admin home page. */
@AdminController('dashboard', 'dashboard')
export class AdminDashboardController {
  constructor(private readonly dashboard: AdminDashboardService) {}

  @Get('summary')
  @ApiOperation({
    summary: 'Headline counts, 30-day trends and the latest admin activity',
  })
  async summary() {
    return { data: await this.dashboard.summary() };
  }
}
