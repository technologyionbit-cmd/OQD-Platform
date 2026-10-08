import { applyDecorators } from '@nestjs/common';
import { Transform } from 'class-transformer';
import { IsString, Matches } from 'class-validator';

/** The one stored and compared shape: E.164 Jordanian mobile (Zain 79,
 *  Orange 77, Umniah 78). */
export const JORDAN_MOBILE_RE = /^\+9627[789][0-9]{7}$/;

/**
 * `07X XXX XXXX`, `7XXXXXXXX`, `9627XXXXXXXX`, `009627XXXXXXXX` and
 * `+9627XXXXXXXX` (spaces, dashes and brackets allowed) -> `+9627XXXXXXXX`.
 * Null for anything that is not a Jordanian mobile number.
 */
export function normalizeJordanMobile(raw: string): string | null {
  if (!/^[\d\s()+-]+$/.test(raw.trim())) return null;
  const digits = raw.replace(/\D/g, '');
  const local = /^(?:00962|962|0)?(7[789][0-9]{7})$/.exec(digits)?.[1];
  return local ? `+962${local}` : null;
}

/**
 * A phone number field: normalized to `+9627XXXXXXXX` before validation,
 * so the service only ever sees (and stores, and looks up) one spelling.
 * Mirrored by the app's `Validators.normalizeJordanMobile`.
 */
export function JordanMobile(): PropertyDecorator {
  return applyDecorators(
    Transform(({ value }: { value: unknown }) =>
      typeof value === 'string' ? (normalizeJordanMobile(value) ?? value) : value,
    ),
    IsString(),
    Matches(JORDAN_MOBILE_RE, {
      message: 'Enter a valid Jordanian mobile number.',
    }),
  );
}
