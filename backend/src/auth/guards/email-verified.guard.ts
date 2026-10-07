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
 * Lets a request through only when the caller's email is verified; else
 * 403 EMAIL_NOT_VERIFIED. Runs after {@link JwtAuthGuard} (it reads
 * `request.user`), so put it on routes that guard already protects.
 *
 * Reads the database on each call rather than trusting a token claim, so
 * verifying (or changing the email) takes effect at once.
 */
@Injectable()
export class EmailVerifiedGuard implements CanActivate {
  constructor(private readonly prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context
      .switchToHttp()
      .getRequest<Request & { user?: AuthenticatedUser }>();
    const userId = request.user?.id;

    const user = userId
      ? await this.prisma.user.findUnique({
          where: { id: userId },
          select: { emailVerifiedAt: true },
        })
      : null;

    if (!user?.emailVerifiedAt) {
      throw forbidden(
        'Verify your email address to continue.',
        ApiErrorCode.EMAIL_NOT_VERIFIED,
      );
    }
    return true;
  }
}

/** Marks a route as needing a verified email (see {@link EmailVerifiedGuard}). */
export function RequireVerifiedEmail() {
  return applyDecorators(
    UseGuards(EmailVerifiedGuard),
    ApiForbiddenResponse({
      type: ApiErrorResponseDto,
      description: 'Email not verified yet (code EMAIL_NOT_VERIFIED).',
    }),
  );
}
