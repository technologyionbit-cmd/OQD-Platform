import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { StorageModule } from '../storage/storage.module';
import { PhoneVerifiedGuard } from '../auth/guards/phone-verified.guard';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  ContractsController,
  ContractTemplatesController,
} from './contracts.controller';
import { ContractTemplateStore } from './contract-template.store';
import { ContractsService } from './contracts.service';

@Module({
  imports: [AuthModule, StorageModule],
  controllers: [ContractTemplatesController, ContractsController],
  // Guards re-declared here (see auth.module.ts's exports comment) so
  // @UseGuards(...) resolves them in this module's own injector.
  providers: [
    ContractsService,
    ContractTemplateStore,
    JwtAuthGuard,
    PhoneVerifiedGuard,
  ],
  // The admin module manages templates through the same store.
  exports: [ContractTemplateStore],
})
export class ContractsModule {}
