import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AvailabilityController } from './availability.controller';
import { ConsultationsController } from './consultations.controller';
import { ConsultationsService } from './consultations.service';

@Module({
  imports: [AuthModule],
  controllers: [ConsultationsController, AvailabilityController],
  // JwtAuthGuard re-declared here (see auth.module.ts's exports comment)
  // so @UseGuards(JwtAuthGuard) resolves in this module's own injector.
  providers: [ConsultationsService, JwtAuthGuard],
})
export class ConsultationsModule {}
