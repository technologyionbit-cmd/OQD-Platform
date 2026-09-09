export interface AppConfig {
  nodeEnv: string;
  port: number;
  isProduction: boolean;
}

export interface DatabaseConfig {
  url: string;
}

export interface RedisConfig {
  url: string;
}

export interface CorsConfig {
  origins: string[];
}

export interface Configuration {
  app: AppConfig;
  database: DatabaseConfig;
  redis: RedisConfig;
  cors: CorsConfig;
}

/**
 * Centralized, namespaced configuration factory consumed via
 * ConfigService.get<T>('app'|'database'|'redis'|'cors').
 *
 * Namespaces reserved for future phases (jwt, storage, ai, payments,
 * push, websocket) are intentionally NOT added here yet — see
 * .env.example and docs/backend/16-backend-roadmap.md for when each lands.
 */
export default (): Configuration => ({
  app: {
    nodeEnv: process.env.NODE_ENV ?? 'development',
    port: parseInt(process.env.PORT ?? '3000', 10),
    isProduction: process.env.NODE_ENV === 'production',
  },
  database: {
    url: process.env.DATABASE_URL ?? '',
  },
  redis: {
    url: process.env.REDIS_URL ?? '',
  },
  cors: {
    origins: (process.env.CORS_ORIGINS ?? '')
      .split(',')
      .map((origin) => origin.trim())
      .filter((origin) => origin.length > 0),
  },
});
