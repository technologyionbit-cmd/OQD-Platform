import { Injectable } from '@nestjs/common';
import {
  HealthIndicatorResult,
  HealthIndicatorService,
} from '@nestjs/terminus';
import { RedisService } from '../../redis/redis.service';

@Injectable()
export class RedisHealthIndicator {
  constructor(
    private readonly healthIndicatorService: HealthIndicatorService,
    private readonly redis: RedisService,
  ) {}

  async pingCheck<Key extends string = string>(
    key: Key,
  ): Promise<HealthIndicatorResult<Key>> {
    const indicator = this.healthIndicatorService.check(key);

    try {
      const ok = await this.redis.ping();
      if (!ok) {
        throw new Error('Unexpected PING reply');
      }
      return indicator.up();
    } catch (error) {
      return indicator.down({ message: (error as Error).message });
    }
  }
}
