import { parseTrustProxy } from './configuration';
import { envValidationSchema } from './env.validation';

describe('parseTrustProxy', () => {
  it.each([undefined, '', '  ', 'false'])(
    'disables proxy trust for %p',
    (raw) => {
      expect(parseTrustProxy(raw)).toBe(false);
    },
  );

  it('reads a hop count as a number', () => {
    expect(parseTrustProxy('1')).toBe(1);
  });

  it('reads a comma-separated allow-list', () => {
    expect(parseTrustProxy('loopback, 10.0.0.0/8')).toEqual([
      'loopback',
      '10.0.0.0/8',
    ]);
  });
});

describe('envValidationSchema TRUST_PROXY', () => {
  const base = {
    DATABASE_URL: 'postgresql://u:p@localhost:5432/db',
    JWT_ACCESS_SECRET: 'x'.repeat(32),
  };

  const validate = (value: string) =>
    envValidationSchema.validate({ ...base, TRUST_PROXY: value }).error;

  it('rejects `true`, which would trust spoofed X-Forwarded-For', () => {
    expect(validate('true')).toBeDefined();
  });

  it.each(['', '1', 'loopback', 'loopback,10.0.0.0/8', '::1'])(
    'accepts %p',
    (value) => {
      expect(validate(value)).toBeUndefined();
    },
  );
});

describe('envValidationSchema TERMS_VERSION', () => {
  const base = {
    DATABASE_URL: 'postgresql://u:p@localhost:5432/db',
    JWT_ACCESS_SECRET: 'x'.repeat(32),
  };

  const validate = (value: string) =>
    envValidationSchema.validate({ ...base, TERMS_VERSION: value }).error;

  it.each(['2026-09-28', 'v2', '1.4'])('accepts %p', (value) => {
    expect(validate(value)).toBeUndefined();
  });

  it.each(['', 'has space', 'x'.repeat(33)])('rejects %p', (value) => {
    expect(validate(value)).toBeDefined();
  });
});
