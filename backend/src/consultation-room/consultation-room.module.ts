import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ConsultationsModule } from '../consultations/consultations.module';
import { ConsultationRoomController } from './consultation-room.controller';
import { ConsultationRoomService } from './consultation-room.service';

@Module({
  imports: [AuthModule, ConsultationsModule],
  controllers: [ConsultationRoomController],
  // JwtAuthGuard re-declared here (see auth.module.ts's exports comment)
  // so @UseGuards(JwtAuthGuard) resolves in this module's own injector.
  providers: [ConsultationRoomService, JwtAuthGuard],
})
export class ConsultationRoomModule {}
