import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { LawyersModule } from '../lawyers/lawyers.module';
import { AdminLawyerVerificationsController } from './admin-lawyer-verifications.controller';
import { AdminGuard } from './admin.guard';

/**
 * Staff-only API. There is no admin app yet: admins call these routes
 * directly (Swagger or curl). An admin is an ordinary account whose role
 * was set to `admin` in the database.
 */
@Module({
  imports: [AuthModule, LawyersModule],
  controllers: [AdminLawyerVerificationsController],
  providers: [JwtAuthGuard, AdminGuard],
})
export class AdminModule {}
