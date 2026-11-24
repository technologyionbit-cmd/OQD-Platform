import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { StorageModule } from '../storage/storage.module';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GovProceduresController } from './gov-procedures.controller';
import { GovProceduresService } from './gov-procedures.service';

@Module({
  imports: [AuthModule, StorageModule],
  controllers: [GovProceduresController],
  // JwtAuthGuard is re-declared here (see auth.module.ts's exports comment)
  // so @UseGuards(JwtAuthGuard) resolves in this module's own injector.
  providers: [GovProceduresService, JwtAuthGuard],
})
export class GovProceduresModule {}
