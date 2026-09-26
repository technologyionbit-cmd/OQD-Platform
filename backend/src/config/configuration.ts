/**
 * Express "trust proxy" setting: `false` (clients connect directly, the
 * default), a hop count, or an allow-list of proxy addresses/subnets/presets
 * (`loopback`, `uniquelocal`...). Never `true` — trusting every hop lets any
 * client spoof `X-Forwarded-For` and dodge per-IP rate limiting.
 */
export type TrustProxySetting = false | number | string[];

export interface AppConfig {
  nodeEnv: string;
  port: number;
  /** Interface to bind. Behind a same-host proxy use 127.0.0.1 so the API
   *  is unreachable except through the proxy (TLS, headers, limits). */
  host: string;
  isProduction: boolean;
  trustProxy: TrustProxySetting;
  /** Serve the OpenAPI UI at /v1/docs. Defaults to on outside production. */
  apiDocsEnabled: boolean;
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
  /** Sign-in attempts allowed per email per window, on top of per-IP limits. */
  loginMaxAttempts: number;
  loginAttemptWindowMinutes: number;
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
    host: process.env.HOST ?? '0.0.0.0',
    isProduction: process.env.NODE_ENV === 'production',
    trustProxy: parseTrustProxy(process.env.TRUST_PROXY),
    apiDocsEnabled:
      process.env.API_DOCS_ENABLED !== undefined
        ? process.env.API_DOCS_ENABLED === 'true'
        : process.env.NODE_ENV !== 'production',
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
    loginMaxAttempts: parseInt(process.env.LOGIN_MAX_ATTEMPTS ?? '10', 10),
    loginAttemptWindowMinutes: parseInt(
      process.env.LOGIN_ATTEMPT_WINDOW_MINUTES ?? '15',
      10,
    ),
  },
});

/** Parses `TRUST_PROXY` (already shape-checked by env.validation.ts). */
export function parseTrustProxy(raw: string | undefined): TrustProxySetting {
  const value = raw?.trim() ?? '';
  if (value === '' || value === 'false') return false;
  if (/^\d+$/.test(value)) return parseInt(value, 10);
  return value
    .split(',')
    .map((entry) => entry.trim())
    .filter((entry) => entry.length > 0);
}
