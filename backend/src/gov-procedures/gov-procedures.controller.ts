import { Body, Controller, Get, Param, Patch, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { UpdateGovProcedureProgressDto } from './dto/update-progress.dto';
import { GovProceduresService } from './gov-procedures.service';

/**
 * All routes require auth even though the catalog itself is public
 * reference content — there's no real benefit to a public/private split
 * here, and keeping every route behind JwtAuthGuard is one less thing to
 * get wrong (docs/plans/individual-user-rollout.md Part 2).
 */
@Controller('gov-procedures')
@UseGuards(JwtAuthGuard)
export class GovProceduresController {
  constructor(private readonly govProcedures: GovProceduresService) {}

  @Get()
  async findAll() {
    return { data: await this.govProcedures.findAll() };
  }

  @Get(':id')
  async findById(@Param('id') id: string) {
    return { data: await this.govProcedures.findById(id) };
  }

  @Get(':id/progress')
  async getProgress(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return { data: await this.govProcedures.getProgress(user.id, id) };
  }

  @Patch(':id/progress')
  async updateProgress(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateGovProcedureProgressDto,
  ) {
    return { data: await this.govProcedures.updateProgress(user.id, id, dto) };
  }
}
