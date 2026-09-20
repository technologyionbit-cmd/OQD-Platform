import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { LawyersController } from './lawyers.controller';
import { LawyersService } from './lawyers.service';

@Module({
  imports: [AuthModule],
  controllers: [LawyersController],
  // JwtAuthGuard re-declared here so @UseGuards(JwtAuthGuard) resolves in
  // this module's own injector (see auth.module.ts's exports comment).
  providers: [LawyersService, JwtAuthGuard],
})
export class LawyersModule {}
