import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { NotificationsModule } from '../notifications/notifications.module';
import { StorageModule } from '../storage/storage.module';
import { LawyerVerificationService } from './lawyer-verification.service';
import { LawyersController } from './lawyers.controller';
import { LawyersService } from './lawyers.service';

@Module({
  imports: [AuthModule, NotificationsModule, StorageModule],
  controllers: [LawyersController],
  // JwtAuthGuard re-declared here so @UseGuards(JwtAuthGuard) resolves in
  // this module's own injector (see auth.module.ts's exports comment).
  providers: [LawyersService, LawyerVerificationService, JwtAuthGuard],
  exports: [LawyersService, LawyerVerificationService],
})
export class LawyersModule {}
