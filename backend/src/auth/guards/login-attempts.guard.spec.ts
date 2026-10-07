import { ExecutionContext, HttpException, HttpStatus } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ThrottlerStorageService } from '@nestjs/throttler';
import { LoginAttemptsGuard } from './login-attempts.guard';

describe('LoginAttemptsGuard', () => {
  const LIMIT = 3;
  let guard: LoginAttemptsGuard;
  let storage: ThrottlerStorageService;
  let headers: Record<string, string>;

  beforeEach(() => {
    storage = new ThrottlerStorageService();
    guard = new LoginAttemptsGuard(storage, {
      get: () => ({ loginMaxAttempts: LIMIT, loginAttemptWindowMinutes: 15 }),
    } as unknown as ConfigService);
    headers = {};
  });

  afterEach(() => storage.onApplicationShutdown());

  const contextFor = (body: unknown) =>
    ({
      switchToHttp: () => ({
        getRequest: () => ({ body }),
        getResponse: () => ({
          header: (name: string, value: string) => (headers[name] = value),
        }),
      }),
    }) as unknown as ExecutionContext;

  const attempt = (email: unknown) =>
    guard.canActivate(contextFor({ email, password: 'x' }));

  it('allows attempts up to the limit, then answers 429 with Retry-After', async () => {
    for (let i = 0; i < LIMIT; i++) {
      await expect(attempt('user@aqd.test')).resolves.toBe(true);
    }

    const blocked = await attempt('user@aqd.test').catch((e: unknown) => e);

    expect(blocked).toBeInstanceOf(HttpException);
    expect((blocked as HttpException).getStatus()).toBe(
      HttpStatus.TOO_MANY_REQUESTS,
    );
    expect(Number(headers['Retry-After'])).toBeGreaterThan(0);
  });

  it('counts case and whitespace variants of an email as the same account', async () => {
    await attempt('User@AQD.test');
    await attempt('  user@aqd.test ');
    await attempt('USER@aqd.TEST');

    await expect(attempt('user@aqd.test')).rejects.toBeInstanceOf(
      HttpException,
    );
  });

  it('keeps separate counters per email', async () => {
    for (let i = 0; i < LIMIT; i++) await attempt('a@aqd.test');

    await expect(attempt('b@aqd.test')).resolves.toBe(true);
  });

  it('leaves malformed bodies to validation', async () => {
    for (let i = 0; i < LIMIT + 2; i++) {
      await expect(attempt(undefined)).resolves.toBe(true);
      await expect(attempt(42)).resolves.toBe(true);
    }
  });
});
