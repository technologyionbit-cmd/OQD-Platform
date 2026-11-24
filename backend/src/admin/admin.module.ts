import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { ContractsModule } from '../contracts/contracts.module';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { LawyersModule } from '../lawyers/lawyers.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { StorageModule } from '../storage/storage.module';
import { AdminLawyerVerificationsController } from './admin-lawyer-verifications.controller';
import { AdminAdminsController, AdminAdminsService } from './admins/admin-admins';
import { AdminGuard } from './admin.guard';
import { AdminAuthController } from './auth/admin-auth.controller';
import { AdminAuthService } from './auth/admin-auth.service';
import { AdminOriginGuard } from './auth/admin-origin.guard';
import { AdminAuditLogsController } from './audit/admin-audit-logs.controller';
import { AdminAuditLogsService } from './audit/admin-audit-logs.service';
import { AuditModule } from './audit/audit.module';
import { AdminCompaniesController } from './companies/admin-companies.controller';
import { AdminCompaniesService } from './companies/admin-companies.service';
import { AdminConsultationsController, AdminConsultationsService } from './consultations/admin-consultations';
import { AdminContractsController, AdminContractsService } from './contracts/admin-contracts';
import { AdminGovProceduresController, AdminGovProceduresService } from './gov-procedures/admin-gov-procedures';
import { AdminNotificationsController, AdminNotificationsService } from './notifications/admin-notifications';
import { AdminContractTemplatesController, AdminContractTemplatesService } from './contract-templates/admin-contract-templates';
import { AdminDashboardController } from './dashboard/admin-dashboard.controller';
import { AdminDashboardService } from './dashboard/admin-dashboard.service';
import { AdminLawyersController } from './lawyers/admin-lawyers.controller';
import { AdminLawyersService } from './lawyers/admin-lawyers.service';
import { AdminUsersController } from './users/admin-users.controller';
import { AdminUsersService } from './users/admin-users.service';

/**
 * Staff-only API for the admin web app (`admin_web/`). An admin is an
 * ordinary account whose role was set to `admin` in the database. Every
 * controller here is declared with `@AdminController` (guards, audit,
 * rate limit); `AdminAuthController` is the sign-in door and the only
 * exception.
 */
@Module({
  imports: [
    AuthModule,
    LawyersModule,
    AuditModule,
    NotificationsModule,
    ContractsModule,
    StorageModule,
  ],
  controllers: [
    AdminLawyerVerificationsController,
    AdminAuthController,
    AdminUsersController,
    AdminAuditLogsController,
    AdminDashboardController,
    AdminLawyersController,
    AdminCompaniesController,
    AdminConsultationsController,
    AdminContractsController,
    AdminGovProceduresController,
    AdminNotificationsController,
    AdminContractTemplatesController,
    AdminAdminsController,
  ],
  providers: [
    JwtAuthGuard,
    AdminGuard,
    AdminAuthService,
    AdminOriginGuard,
    AdminUsersService,
    AdminAuditLogsService,
    AdminDashboardService,
    AdminLawyersService,
    AdminCompaniesService,
    AdminConsultationsService,
    AdminContractsService,
    AdminGovProceduresService,
    AdminNotificationsService,
    AdminContractTemplatesService,
    AdminAdminsService,
  ],
})
export class AdminModule {}
