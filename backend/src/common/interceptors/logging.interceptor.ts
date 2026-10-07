import {
  CallHandler,
  ExecutionContext,
  HttpException,
  HttpStatus,
  Injectable,
  Logger,
  NestInterceptor,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { randomUUID } from 'node:crypto';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

const REQUEST_ID_HEADER = 'x-request-id';

/**
 * Structured request logging foundation: assigns a request id (reusing an
 * inbound one if the client/proxy already set it), logs method/path/status/
 * duration, and never logs request/response bodies — those may contain
 * passwords, tokens, or contract PII (docs/backend/14-security.md
 * "Sensitive data" / "Authentication").
 */
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const httpContext = context.switchToHttp();
    const request = httpContext.getRequest<Request>();
    const response = httpContext.getResponse<Response>();

    const requestId =
      (request.headers[REQUEST_ID_HEADER] as string | undefined) ??
      randomUUID();
    response.setHeader(REQUEST_ID_HEADER, requestId);

    const { method, originalUrl } = request;
    const start = Date.now();

    return next.handle().pipe(
      tap({
        next: () => {
          this.logger.log(
            `[${requestId}] ${method} ${originalUrl} ${response.statusCode} +${Date.now() - start}ms`,
          );
        },
        // The response status is not set yet when the handler throws (it
        // still holds the route default, e.g. 204), so log the status the
        // exception filter is about to send.
        error: (error: unknown) => {
          const status =
            error instanceof HttpException
              ? error.getStatus()
              : HttpStatus.INTERNAL_SERVER_ERROR;
          this.logger.log(
            `[${requestId}] ${method} ${originalUrl} ${status} +${Date.now() - start}ms (error)`,
          );
        },
      }),
    );
  }
}
