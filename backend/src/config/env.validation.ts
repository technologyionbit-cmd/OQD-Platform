import * as Joi from 'joi';

/**
 * Validated at process startup via ConfigModule.forRoot({ validationSchema }).
 * Only variables actually consumed in this phase are required — variables
 * reserved for later phases (JWT, storage, AI, payments, push, WS) are
 * intentionally not listed here yet; see .env.example.
 */
export const envValidationSchema = Joi.object({
  NODE_ENV: Joi.string()
    .valid('development', 'test', 'production')
    .default('development'),
  PORT: Joi.number().port().default(3000),
  DATABASE_URL: Joi.string().uri().required(),
  REDIS_URL: Joi.string().uri().required(),
  CORS_ORIGINS: Joi.string().allow('').default(''),
});
