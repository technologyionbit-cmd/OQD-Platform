import { ConfigService } from '@nestjs/config';
import { RedisService } from './redis.service';

function createService(): RedisService {
  const configService = {
    get: () => ({ url: 'redis://localhost:6379' }),
  } as unknown as ConfigService;

  return new RedisService(configService);
}

describe('RedisService', () => {
  it('reports healthy when the client responds PONG', async () => {
    const service = createService();
    (service as unknown as { client: { ping: jest.Mock } }).client = {
      ping: jest.fn().mockResolvedValue('PONG'),
    };

    await expect(service.ping()).resolves.toBe(true);
  });

  it('reports unhealthy when the client returns an unexpected reply', async () => {
    const service = createService();
    (service as unknown as { client: { ping: jest.Mock } }).client = {
      ping: jest.fn().mockResolvedValue('WRONG'),
    };

    await expect(service.ping()).resolves.toBe(false);
  });

  it('quits the client cleanly on module destroy', async () => {
    const service = createService();
    const quit = jest.fn().mockResolvedValue(undefined);
    (service as unknown as { client: { quit: jest.Mock } }).client = {
      quit,
    };

    await service.onModuleDestroy();

    expect(quit).toHaveBeenCalledTimes(1);
  });
});
