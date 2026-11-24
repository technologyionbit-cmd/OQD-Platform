import {
  applyDecorators,
  Controller,
  SetMetadata,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { ApiBearerAuth, ApiForbiddenResponse, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { ApiErrorResponseDto } from '../../common/openapi/api-error.dto';
import { BEARER_AUTH } from '../../common/openapi/setup-openapi';
import { AdminGuard } from '../admin.guard';
import { AdminAuditInterceptor } from '../audit/audit.interceptor';
import {
  ADMIN_MODULE_KEY,
  type AdminModule,
} from '../permissions/admin-permissions';

/** Per-IP ceiling for every admin route (the global default is 120/min). */
export const ADMIN_THROTTLE = { default: { limit: 90, ttl: 60_000 } };
/** For writes that fan out or export data; put on the method. */
export const ADMIN_HEAVY_THROTTLE = { default: { limit: 10, ttl: 60_000 } };

/**
 * Every admin controller uses this instead of `@Controller`: it puts the
 * route behind JwtAuthGuard + AdminGuard, audits every write, rate-limits,
 * and documents the 403 in Swagger, so none of it can be forgotten.
 *
 * [module] is the permission area. Leave it out for routes only a
 * full-access admin may use (managing other admins).
 */
export const AdminController = (path: string, module?: AdminModule) =>
  applyDecorators(
    ApiTags('admin'),
    ApiBearerAuth(BEARER_AUTH),
    ApiForbiddenResponse({
      type: ApiErrorResponseDto,
      description: 'The caller is not an admin, or lacks this permission.',
    }),
    Controller(`admin/${path}`),
    SetMetadata(ADMIN_MODULE_KEY, module ?? null),
    UseGuards(JwtAuthGuard, AdminGuard),
    UseInterceptors(AdminAuditInterceptor),
    Throttle(ADMIN_THROTTLE),
  );
