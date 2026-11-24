/* eslint-disable @typescript-eslint/unbound-method */
import {
  CallHandler,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { lastValueFrom, of, throwError } from 'rxjs';
import { AuditAction, AuditRead } from './audit.decorators';
import { AdminAuditInterceptor } from './audit.interceptor';
import type { AuditService } from './audit.service';

class Handlers {
  @AuditAction('thing.do')
  named(): void {}
  plain(): void {}
  @AuditRead('thing.export')
  exported(): void {}
}

function setup(method: string, handler: () => void, request: object = {}) {
  const record = jest
    .fn<Promise<void>, [Record<string, unknown>]>()
    .mockResolvedValue(undefined);
  const interceptor = new AdminAuditInterceptor(
    { record } as unknown as AuditService,
    new Reflector(),
  );
  const req = {
    method,
    ip: '1.2.3.4',
    headers: { 'user-agent': 'jest' },
    user: { id: 'admin-1' },
    params: { id: 'abc' },
    body: { reason: 'r', password: 'secret' },
    baseUrl: '/v1/admin/things',
    route: { path: '/:id/do' },
    ...request,
  };
  const ctx = {
    switchToHttp: () => ({
      getRequest: () => req,
      getResponse: () => ({ statusCode: 204 }),
    }),
    getHandler: () => handler,
    getClass: () => Handlers,
  } as unknown as ExecutionContext;
  return { interceptor, ctx, record };
}

const ok: CallHandler = { handle: () => of(undefined) };

describe('AdminAuditInterceptor', () => {
  it('records a successful write with actor, action, entity and redacted body', async () => {
    const h = new Handlers();
    const { interceptor, ctx, record } = setup('POST', h.named);

    await lastValueFrom(interceptor.intercept(ctx, ok));

    expect(record).toHaveBeenCalledTimes(1);
    const entry = record.mock.calls[0][0];
    expect(entry).toMatchObject({
      actorUserId: 'admin-1',
      action: 'thing.do',
      entityId: 'abc',
      method: 'POST',
      path: '/v1/admin/things/:id/do',
      statusCode: 204,
      ipAddress: '1.2.3.4',
    });
    expect(JSON.stringify(entry.meta)).not.toContain('secret');
  });

  it('falls back to "METHOD route" and uses the note when present', async () => {
    const h = new Handlers();
    const { interceptor, ctx, record } = setup('PATCH', h.plain, {
      auditNote: {
        entityType: 'user',
        entityId: 'u9',
        before: { a: 1 },
        after: { a: 2 },
      },
    });
    await lastValueFrom(interceptor.intercept(ctx, ok));
    expect(record.mock.calls[0][0]).toMatchObject({
      action: 'PATCH /v1/admin/things/:id/do',
      entityType: 'user',
      entityId: 'u9',
      before: { a: 1 },
      after: { a: 2 },
    });
  });

  it('records a failed write with the error status', async () => {
    const h = new Handlers();
    const { interceptor, ctx, record } = setup('DELETE', h.named);
    await expect(
      lastValueFrom(
        interceptor.intercept(ctx, {
          handle: () => throwError(() => new ForbiddenException()),
        }),
      ),
    ).rejects.toBeInstanceOf(ForbiddenException);
    expect(record.mock.calls[0][0]).toMatchObject({ statusCode: 403 });
  });

  it('never records reads', async () => {
    const h = new Handlers();
    const { interceptor, ctx, record } = setup('GET', h.named);
    await lastValueFrom(interceptor.intercept(ctx, ok));
    expect(record).not.toHaveBeenCalled();
  });

  it('records a GET only when the handler is marked @AuditRead', async () => {
    const h = new Handlers();
    const { interceptor, ctx, record } = setup('GET', h.exported);
    await lastValueFrom(interceptor.intercept(ctx, ok));
    expect(record).toHaveBeenCalledTimes(1);
    expect(record.mock.calls[0][0]).toMatchObject({ action: 'thing.export', method: 'GET' });
  });
});
