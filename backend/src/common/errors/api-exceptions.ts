import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  NotFoundException,
  UnauthorizedException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { ApiErrorCode } from './api-error-codes';
/**
 * The one place that builds error responses in the API's envelope
 * (`{ message, code, errors? }`, docs/backend/05-api-design.md §4), so
 * services say what went wrong instead of repeating the shape.
 */

export const badRequest = (message: string) =>
  new BadRequestException({ message, code: ApiErrorCode.BAD_REQUEST });

export const unauthorized = (message: string) =>
  new UnauthorizedException({ message, code: ApiErrorCode.UNAUTHORIZED });

export const forbidden = (
  message: string,
  code: ApiErrorCode = ApiErrorCode.FORBIDDEN,
) => new ForbiddenException({ message, code });

/** Missing, or someone else's: both answer the same so ids cannot be probed. */
export const notFound = (message: string) =>
  new NotFoundException({ message, code: ApiErrorCode.NOT_FOUND });

export const conflict = (
  message: string,
  code: ApiErrorCode = ApiErrorCode.CONFLICT,
) => new ConflictException({ message, code });

/** 422 with per-field messages, the shape the app shows next to inputs. */
export const validationFailed = (
  errors: Record<string, string[]>,
  message = 'Validation failed',
  code: ApiErrorCode = ApiErrorCode.VALIDATION_ERROR,
) => new UnprocessableEntityException({ message, code, errors });
