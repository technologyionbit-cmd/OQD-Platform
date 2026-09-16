import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import type { Server } from 'node:http';
import request from 'supertest';
import { AppModule } from '../src/app.module';

/**
 * Requires PostgreSQL reachable at DATABASE_URL (see README.md), since
 * PrismaModule connects eagerly on application bootstrap.
 */
describe('GET /v1/health (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleRef.createNestApplication();
    app.setGlobalPrefix('v1');
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('reports ok with the database up when infrastructure is reachable', async () => {
    const res = await request(app.getHttpServer() as Server).get('/v1/health');

    expect(res.status).toBe(200);
    expect(res.body).toMatchObject({
      status: 'ok',
      details: {
        database: { status: 'up' },
      },
    });
  });
});
