import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UseGuards,
  applyDecorators,
} from '@nestjs/common';
import { ApiErrorCode } from '../../common/errors/api-error-codes';
import { ApiForbiddenResponse } from '@nestjs/swagger';
import type { Request } from 'express';
import { forbidden } from '../../common/errors/api-exceptions';
import { ApiErrorResponseDto } from '../../common/openapi/api-error.dto';
import { PrismaService } from '../../prisma/prisma.service';
import type { AuthenticatedUser } from '../auth.types';

/**
 * Lets a request through only when the caller's phone number is verified;
 * else 403 PHONE_NOT_VERIFIED. Runs after {@link JwtAuthGuard} (it reads
 * `request.user`), so put it on routes that guard already protects.
 *
 * Reads the database on each call rather than trusting a token claim, so
 * verifying takes effect at once.
 */
@Injectable()
export class PhoneVerifiedGuard implements CanActivate {
  constructor(private readonly prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context
      .switchToHttp()
      .getRequest<Request & { user?: AuthenticatedUser }>();
    const userId = request.user?.id;

    const user = userId
      ? await this.prisma.user.findUnique({
          where: { id: userId },
          select: { phoneVerifiedAt: true },
        })
      : null;

    if (!user?.phoneVerifiedAt) {
      throw forbidden(
        'Verify your phone number to continue.',
        ApiErrorCode.PHONE_NOT_VERIFIED,
      );
    }
    return true;
  }
}

/** Marks a route as needing a verified phone (see {@link PhoneVerifiedGuard}). */
export function RequireVerifiedPhone() {
  return applyDecorators(
    UseGuards(PhoneVerifiedGuard),
    ApiForbiddenResponse({
      type: ApiErrorResponseDto,
      description: 'Phone number not verified yet (code PHONE_NOT_VERIFIED).',
    }),
  );
}
