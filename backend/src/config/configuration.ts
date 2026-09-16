export interface AppConfig {
  nodeEnv: string;
  port: number;
  isProduction: boolean;
}

export interface DatabaseConfig {
  url: string;
}

export interface CorsConfig {
  origins: string[];
}

export interface JwtConfig {
  accessSecret: string;
  accessTtl: string;
  refreshTtlDays: number;
}

export interface AuthConfig {
  bcryptRounds: number;
  otpTtlMinutes: number;
  otpMaxAttempts: number;
}

export interface Configuration {
  app: AppConfig;
  database: DatabaseConfig;
  cors: CorsConfig;
  jwt: JwtConfig;
  auth: AuthConfig;
}

/**
 * Centralized, namespaced configuration factory consumed via
 * ConfigService.get<T>('app'|'database'|'cors'|'jwt'|'auth').
 *
 * Namespaces reserved for later phases (storage, ai, payments, push,
 * websocket) are intentionally NOT added here yet — see .env.example and
 * docs/backend/16-backend-roadmap.md for when each lands.
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
  cors: {
    origins: (process.env.CORS_ORIGINS ?? '')
      .split(',')
      .map((origin) => origin.trim())
      .filter((origin) => origin.length > 0),
  },
  jwt: {
    accessSecret: process.env.JWT_ACCESS_SECRET ?? '',
    accessTtl: process.env.JWT_ACCESS_TTL ?? '15m',
    refreshTtlDays: parseInt(process.env.REFRESH_TTL_DAYS ?? '30', 10),
  },
  auth: {
    bcryptRounds: parseInt(process.env.BCRYPT_ROUNDS ?? '12', 10),
    otpTtlMinutes: parseInt(process.env.OTP_TTL_MINUTES ?? '10', 10),
    otpMaxAttempts: parseInt(process.env.OTP_MAX_ATTEMPTS ?? '5', 10),
  },
});
