import { REDACTED, sanitizeForAudit } from './audit-sanitize';

describe('sanitizeForAudit', () => {
  it('redacts secret-looking keys at any depth', () => {
    const out = sanitizeForAudit({
      reason: 'ok',
      password: 'p',
      nested: { refreshToken: 't', otpCode: '1', keep: 1 },
    });
    expect(out).toEqual({
      reason: 'ok',
      password: REDACTED,
      nested: { refreshToken: REDACTED, otpCode: REDACTED, keep: 1 },
    });
  });

  it('cuts long strings, deep trees and long arrays', () => {
    expect((sanitizeForAudit('x'.repeat(600)) as string).length).toBe(503);
    let deep: unknown = 'leaf';
    for (let i = 0; i < 10; i++) deep = { a: deep };
    expect(JSON.stringify(sanitizeForAudit(deep))).toContain('[truncated]');
    expect((sanitizeForAudit(new Array(80).fill(1)) as unknown[]).length).toBe(
      50,
    );
  });

  it('maps null, undefined and dates to JSON-safe values', () => {
    expect(sanitizeForAudit(undefined)).toBeNull();
    expect(sanitizeForAudit(new Date('2026-01-01T00:00:00Z'))).toBe(
      '2026-01-01T00:00:00.000Z',
    );
  });
});
