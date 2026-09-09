import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { resolveApiErrorCode } from '../errors/api-error-codes';
import type { ApiErrorEnvelope } from '../errors/api-error-envelope';

interface KnownErrorResponseShape {
  message?: string | string[];
  code?: string;
  errors?: Record<string, string[]>;
}

/**
 * Global exception filter — the single place that turns any thrown error
 * (HttpException or not) into the API error envelope from
 * docs/backend/05-api-design.md §4. Never leaks stack traces or internal
 * error details to the client; those are logged server-side only.
 */
@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger('ExceptionFilter');

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const body = this.buildEnvelope(exception, status);

    const logLine = `${request.method} ${request.url} -> ${status}: ${body.error.message}`;
    if (status >= 500) {
      this.logger.error(
        logLine,
        exception instanceof Error ? exception.stack : undefined,
      );
    } else if (status >= 400) {
      this.logger.warn(logLine);
    }

    response.status(status).json(body);
  }

  private buildEnvelope(exception: unknown, status: number): ApiErrorEnvelope {
    if (exception instanceof HttpException) {
      const raw = exception.getResponse();

      if (typeof raw === 'object' && raw !== null) {
        const shaped = raw as KnownErrorResponseShape;
        const message = Array.isArray(shaped.message)
          ? shaped.message.join(', ')
          : (shaped.message ?? exception.message);

        return {
          error: {
            message,
            code: shaped.code ?? resolveApiErrorCode(status),
            ...(shaped.errors ? { errors: shaped.errors } : {}),
          },
        };
      }

      return {
        error: {
          message: typeof raw === 'string' ? raw : exception.message,
          code: resolveApiErrorCode(status),
        },
      };
    }

    // Unknown/unhandled error: safe, generic message only — details go to
    // the server log above, never to the response body.
    return {
      error: {
        message: 'An unexpected error occurred.',
        code: resolveApiErrorCode(status),
      },
    };
  }
}
