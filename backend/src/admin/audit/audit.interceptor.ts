import {
  CallHandler,
  ExecutionContext,
  HttpException,
  HttpStatus,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import type { Response } from 'express';
import { Observable, tap } from 'rxjs';
import { sanitizeForAudit } from './audit-sanitize';
import { AUDIT_ACTION, AUDIT_READ, AUDIT_SKIP } from './audit.decorators';
import { AuditService } from './audit.service';
import type { AuditedRequest } from './audit.types';

const WRITE_METHODS = new Set(['POST', 'PUT', 'PATCH', 'DELETE']);

/**
 * Records every admin write, successful or not, in the audit log: who
 * (from the verified token), what (the `@AuditAction` name, else
 * `METHOD route`), which entity and its before/after (what the handler
 * noted), from where, and how it ended. GETs are recorded only for `@AuditRead` handlers.
 */
@Injectable()
export class AdminAuditInterceptor implements NestInterceptor {
  constructor(
    private readonly audit: AuditService,
    private readonly reflector: Reflector,
  ) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const http = context.switchToHttp();
    const request = http.getRequest<AuditedRequest>();
    const targets = [context.getHandler(), context.getClass()];
    const auditedRead = this.reflector.getAllAndOverride<boolean>(
      AUDIT_READ,
      targets,
    );
    if (!WRITE_METHODS.has(request.method) && !auditedRead) {
      return next.handle();
    }
    if (this.reflector.getAllAndOverride<boolean>(AUDIT_SKIP, targets)) {
      return next.handle();
    }
    const action =
      this.reflector.getAllAndOverride<string | undefined>(
        AUDIT_ACTION,
        targets,
      ) ?? `${request.method} ${this.routeOf(request)}`;

    const write = (statusCode: number) =>
      void this.audit.record({
        actorUserId: request.user?.id ?? null,
        action,
        entityType: request.auditNote?.entityType,
        entityId: request.auditNote?.entityId ?? this.entityIdOf(request),
        method: request.method,
        path: this.routeOf(request),
        statusCode,
        ipAddress: request.ip ?? null,
        userAgent: request.headers['user-agent'] ?? null,
        before: request.auditNote?.before,
        after: request.auditNote?.after,
        meta: {
          ...request.auditNote?.meta,
          params: request.params,
          body: sanitizeForAudit(request.body),
        },
      });

    const response = http.getResponse<Response>();
    return next.handle().pipe(
      tap({
        next: () => write(response.statusCode),
        error: (error: unknown) =>
          write(
            error instanceof HttpException
              ? error.getStatus()
              : HttpStatus.INTERNAL_SERVER_ERROR,
          ),
      }),
    );
  }

  /** `/v1/admin/users/:id/suspend`, not the concrete URL with ids in it. */
  private routeOf(request: AuditedRequest): string {
    const route = (request.route as { path?: string } | undefined)?.path;
    return `${request.baseUrl ?? ''}${route ?? request.path}`;
  }

  private entityIdOf(request: AuditedRequest): string | undefined {
    const params = request.params as Record<string, string | undefined>;
    return params.id ?? Object.values(params).find((v) => !!v);
  }
}
