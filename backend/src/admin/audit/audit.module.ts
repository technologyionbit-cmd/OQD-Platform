import { Module } from '@nestjs/common';
import { AdminAuditInterceptor } from './audit.interceptor';
import { AuditService } from './audit.service';

@Module({
  providers: [AuditService, AdminAuditInterceptor],
  exports: [AuditService, AdminAuditInterceptor],
})
export class AuditModule {}
