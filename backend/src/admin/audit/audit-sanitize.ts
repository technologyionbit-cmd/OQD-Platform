/**
 * Removes secrets from anything about to be stored in the audit log:
 * passwords, tokens, codes and the like are replaced by a marker, long
 * strings and deep structures are cut. Pure, so it is easy to test.
 */

const SECRET_KEY = /pass(word)?|token|secret|otp|code|authorization|cookie/i;
const MAX_STRING = 500;
const MAX_DEPTH = 5;
const MAX_KEYS = 50;
const MAX_ITEMS = 50;
export const REDACTED = '[redacted]';

export function sanitizeForAudit(value: unknown, depth = 0): unknown {
  if (value === null || value === undefined) return null;
  if (typeof value === 'string') {
    return value.length > MAX_STRING ? `${value.slice(0, MAX_STRING)}...` : value;
  }
  if (typeof value === 'number' || typeof value === 'boolean') return value;
  if (value instanceof Date) return value.toISOString();
  if (typeof value === 'bigint') return value.toString();
  if (depth >= MAX_DEPTH) return '[truncated]';
  if (Array.isArray(value)) {
    return value
      .slice(0, MAX_ITEMS)
      .map((item) => sanitizeForAudit(item, depth + 1));
  }
  if (typeof value === 'object') {
    const out: Record<string, unknown> = {};
    for (const [key, item] of Object.entries(value).slice(0, MAX_KEYS)) {
      out[key] = SECRET_KEY.test(key)
        ? REDACTED
        : sanitizeForAudit(item, depth + 1);
    }
    return out;
  }
  return null;
}
