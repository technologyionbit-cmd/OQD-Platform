import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import type { ConfigService } from '@nestjs/config';
import { AdminOriginGuard } from './admin-origin.guard';

const guard = (origins: string[], isProduction: boolean) =>
  new AdminOriginGuard({
    get: (key: string) => (key === 'cors' ? { origins } : { isProduction }),
  } as unknown as ConfigService);

const ctx = (headers: Record<string, string>) =>
  ({
    switchToHttp: () => ({ getRequest: () => ({ headers }) }),
  }) as unknown as ExecutionContext;

const ADMIN = 'https://admin.oqdjo.com';

describe('AdminOriginGuard', () => {
  it('needs the custom client header', () => {
    expect(() =>
      guard([ADMIN], true).canActivate(ctx({ origin: ADMIN })),
    ).toThrow(ForbiddenException);
  });

  it('accepts an allowed origin with the header', () => {
    expect(
      guard([ADMIN], true).canActivate(
        ctx({ 'x-requested-with': 'aqd-admin', origin: ADMIN }),
      ),
    ).toBe(true);
  });

  it('refuses another origin', () => {
    expect(() =>
      guard([ADMIN], true).canActivate(
        ctx({
          'x-requested-with': 'aqd-admin',
          origin: 'https://evil.example',
        }),
      ),
    ).toThrow(ForbiddenException);
  });

  it('allows any origin only outside production with no allow-list', () => {
    const headers = {
      'x-requested-with': 'aqd-admin',
      origin: 'http://localhost:5000',
    };
    expect(guard([], false).canActivate(ctx(headers))).toBe(true);
    expect(() => guard([], true).canActivate(ctx(headers))).toThrow(
      ForbiddenException,
    );
  });
});
