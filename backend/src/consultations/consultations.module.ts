import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { LawyersModule } from '../lawyers/lawyers.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { PhoneVerifiedGuard } from '../auth/guards/phone-verified.guard';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AvailabilityController } from './availability.controller';
import { ConsultationsController } from './consultations.controller';
import { ConsultationsService } from './consultations.service';

@Module({
  imports: [AuthModule, NotificationsModule, LawyersModule],
  controllers: [ConsultationsController, AvailabilityController],
  // Guards re-declared here (see auth.module.ts's exports comment) so
  // @UseGuards(...) resolves them in this module's own injector.
  providers: [ConsultationsService, JwtAuthGuard, PhoneVerifiedGuard],
  exports: [ConsultationsService],
})
export class ConsultationsModule {}
