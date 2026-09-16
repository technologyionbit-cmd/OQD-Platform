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
  DATABASE_URL: Joi.string().uri().required(),
  CORS_ORIGINS: Joi.string().allow('').default(''),

  // Auth (docs/backend/02-auth-and-authorization.md)
  JWT_ACCESS_SECRET: Joi.string().min(32).required(),
  JWT_ACCESS_TTL: Joi.string().default('15m'),
  REFRESH_TTL_DAYS: Joi.number().integer().min(1).default(30),
  BCRYPT_ROUNDS: Joi.number().integer().min(10).max(15).default(12),
  OTP_TTL_MINUTES: Joi.number().integer().min(1).default(10),
  OTP_MAX_ATTEMPTS: Joi.number().integer().min(1).default(5),
});
