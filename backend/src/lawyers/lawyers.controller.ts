import {
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { QueryLawyersDto } from './dto/query-lawyers.dto';
import { QueryReviewsDto } from './dto/query-reviews.dto';
import { LawyersService } from './lawyers.service';

/**
 * Client-facing marketplace search/browse only
 * (docs/plans/individual-user-rollout.md Part 3). Lawyer self-service
 * (/v1/lawyers/me, verification submission) and admin verify/reject are
 * lawyer-side — out of scope here.
 */
@Controller('lawyers')
@UseGuards(JwtAuthGuard)
export class LawyersController {
  constructor(private readonly lawyers: LawyersService) {}

  @Get()
  findAll(@Query() query: QueryLawyersDto) {
    return this.lawyers.findAll(query);
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
