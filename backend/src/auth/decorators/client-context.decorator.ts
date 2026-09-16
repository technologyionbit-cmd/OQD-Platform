import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { Request } from 'express';
import type { RequestContext } from '../auth.types';

/** Device/network context for the calling request, stamped onto each new
 *  `RefreshToken` row so the Active Sessions UI has something to show. */
export const ClientContext = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): RequestContext => {
    const request = ctx.switchToHttp().getRequest<Request>();
    const userAgent = request.headers['user-agent'];
    return {
      deviceLabel:
        typeof userAgent === 'string' && userAgent.length > 0
          ? userAgent.slice(0, 255)
          : null,
      ipAddress: request.ip ?? null,
    };
  },
);
