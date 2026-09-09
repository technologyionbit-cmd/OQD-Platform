import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import type { Server } from 'node:http';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { validationExceptionFactory } from '../src/common/pipes/validation-exception-factory';

/**
 * Requires PostgreSQL + Redis reachable at DATABASE_URL/REDIS_URL
 * (`docker compose up -d` from backend/, per README.md), since PrismaModule
 * and RedisModule connect eagerly on application bootstrap.
 */
describe('Application bootstrap (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleRef.createNestApplication();
    app.setGlobalPrefix('v1');
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
        exceptionFactory: validationExceptionFactory,
      }),
    );
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('boots successfully and applies the /v1 global prefix', async () => {
    const res = await request(app.getHttpServer() as Server).get('/v1/health');
    expect([200, 503]).toContain(res.status);
  });

  it('returns the standard error envelope for an unknown route', async () => {
    const res = await request(app.getHttpServer() as Server).get(
      '/v1/does-not-exist',
    );

    const body = res.body as { error: { message: string; code: string } };

    expect(res.status).toBe(404);
    expect(body).toEqual({
      error: {
        message: expect.any(String) as string,
        code: 'NOT_FOUND',
      },
    });
  });
});
