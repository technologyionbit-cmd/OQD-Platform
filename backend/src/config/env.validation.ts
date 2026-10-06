import * as Joi from 'joi';

/**
 * Validated at process startup via ConfigModule.forRoot({ validationSchema }).
 * Only variables actually consumed in the current phase are listed —
 * variables reserved for later phases (storage, AI, payments, push, WS)
 * are intentionally not listed here yet; see .env.example.
 */
export const envValidationSchema = Joi.object({
  NODE_ENV: Joi.string()
    .valid('development', 'test', 'production')
    .default('development'),
  PORT: Joi.number().port().default(3000),
  HOST: Joi.alternatives()
    .try(Joi.string().ip(), Joi.string().valid('localhost'))
    .default('0.0.0.0'),
  DATABASE_URL: Joi.string().uri().required(),
  CORS_ORIGINS: Joi.string().allow('').default(''),
  // Hop count or comma-separated proxy addresses/presets — see
  // TrustProxySetting. `true` is rejected on purpose (IP spoofing).
  TRUST_PROXY: Joi.string()
    .allow('')
    .invalid('true')
    .pattern(/^[\w.:/,\s-]*$/)
    .default(''),
  API_DOCS_ENABLED: Joi.boolean().truthy('true').falsy('false'),

  // Auth (docs/backend/02-auth-and-authorization.md)
  JWT_ACCESS_SECRET: Joi.string().min(32).required(),
  JWT_ACCESS_TTL: Joi.string().default('15m'),
  REFRESH_TTL_DAYS: Joi.number().integer().min(1).default(30),
  BCRYPT_ROUNDS: Joi.number().integer().min(10).max(15).default(12),
  OTP_TTL_MINUTES: Joi.number().integer().min(1).default(10),
  OTP_MAX_ATTEMPTS: Joi.number().integer().min(1).default(5),
  LOGIN_MAX_ATTEMPTS: Joi.number().integer().min(1).default(10),
  LOGIN_ATTEMPT_WINDOW_MINUTES: Joi.number().integer().min(1).default(15),
  OTP_RESEND_COOLDOWN_SECONDS: Joi.number()
    .integer()
    .min(0)
    .default(60),
  OTP_MAX_PER_HOUR: Joi.number().integer().min(1).default(5),
  TERMS_VERSION: Joi.string()
    .max(32)
    .pattern(/^[\w.-]+$/),

  // Storage — a relative path resolves against the working directory.
  UPLOADS_DIR: Joi.string().default('storage/uploads'),
});
