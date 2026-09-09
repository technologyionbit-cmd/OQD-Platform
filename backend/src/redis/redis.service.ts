import {
  Inject,
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Redis } from 'ioredis';
import type { RedisConfig } from '../config/configuration';

export const REDIS_CLIENT = Symbol('REDIS_CLIENT');

/**
 * Thin, reusable Redis wrapper. Deliberately exposes only connection
 * lifecycle + a health ping in this phase — caching strategy, presence,
 * queues, and rate limiting are later phases (docs/backend/16-backend-roadmap.md),
 * but they will all inject this same service rather than opening their own
 * connection.
 */
@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);
  private client!: Redis;

  constructor(
    @Inject(ConfigService) private readonly configService: ConfigService,
  ) {}

  onModuleInit(): void {
    const { url } = this.configService.get<RedisConfig>('redis')!;

    this.client = new Redis(url, {
      lazyConnect: false,
      maxRetriesPerRequest: 3,
    });

    this.client.on('error', (error: Error) => {
      this.logger.error(`Redis connection error: ${error.message}`);
    });

    this.client.on('connect', () => {
      this.logger.log('Connected to Redis');
    });
  }

  async onModuleDestroy(): Promise<void> {
    await this.client.quit();
    this.logger.log('Disconnected from Redis');
  }

  getClient(): Redis {
    return this.client;
  }

  async ping(): Promise<boolean> {
    const reply = await this.client.ping();
    return reply === 'PONG';
  }
}
