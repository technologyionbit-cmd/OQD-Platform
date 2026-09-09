import { Test } from '@nestjs/testing';
import { HealthCheckService, PrismaHealthIndicator } from '@nestjs/terminus';
import { PrismaService } from '../prisma/prisma.service';
import { HealthController } from './health.controller';
import { RedisHealthIndicator } from './indicators/redis.health-indicator';

describe('HealthController', () => {
  it('aggregates the database and redis indicators through HealthCheckService', async () => {
    const check = jest
      .fn()
      .mockImplementation(
        async (indicators: Array<() => Promise<Record<string, unknown>>>) => {
          const results = await Promise.all(indicators.map((fn) => fn()));
          const merged = Object.assign({}, ...results) as Record<
            string,
            unknown
          >;
          return {
            status: 'ok',
            info: merged,
            error: {},
            details: merged,
          };
        },
      );

    const moduleRef = await Test.createTestingModule({
      controllers: [HealthController],
      providers: [
        { provide: HealthCheckService, useValue: { check } },
        { provide: PrismaService, useValue: {} },
        {
          provide: PrismaHealthIndicator,
          useValue: {
            pingCheck: jest
              .fn()
              .mockResolvedValue({ database: { status: 'up' } }),
          },
        },
        {
          provide: RedisHealthIndicator,
          useValue: {
            pingCheck: jest.fn().mockResolvedValue({ redis: { status: 'up' } }),
          },
        },
      ],
    }).compile();

    const controller = moduleRef.get(HealthController);
    const result = await controller.check();

    expect(check).toHaveBeenCalledTimes(1);
    expect(result.status).toBe('ok');
    expect(result.details).toMatchObject({
      database: { status: 'up' },
      redis: { status: 'up' },
    });
  });
});
