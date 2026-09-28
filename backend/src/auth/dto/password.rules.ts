import { applyDecorators } from '@nestjs/common';
import {
  IsString,
  Matches,
  MinLength,
  ValidateBy,
  type ValidationOptions,
} from 'class-validator';

/**
 * bcrypt only reads the first 72 bytes of its input, so a longer password
 * would be silently truncated: two different passwords sharing a 72-byte
 * prefix would both be accepted. Counted in UTF-8 bytes, not characters —
 * one Arabic letter is 2 bytes.
 */
export const PASSWORD_MAX_BYTES = 72;
export const PASSWORD_MIN_LENGTH = 8;

const PASSWORD_RE = /^(?=.*[A-Za-z])(?=.*\d).+$/;

/** Rejects strings longer than [max] bytes when UTF-8 encoded. */
export function MaxBytes(
  max: number,
  options?: ValidationOptions,
): PropertyDecorator {
  return ValidateBy(
    {
      name: 'maxBytes',
      constraints: [max],
      validator: {
        validate: (value: unknown) =>
          typeof value === 'string' && Buffer.byteLength(value, 'utf8') <= max,
      },
    },
    options,
  );
}

/**
 * Rules for every password the server will hash (register, change,
 * reset) — mirrored by the app's `Validators` so the form catches the
 * same mistakes before submitting.
 */
export function StrongPassword(): PropertyDecorator {
  return applyDecorators(
    IsString(),
    MinLength(PASSWORD_MIN_LENGTH, {
      message: 'Password must be at least 8 characters.',
    }),
    MaxBytes(PASSWORD_MAX_BYTES, {
      message: 'Password must be at most 72 bytes.',
    }),
    Matches(PASSWORD_RE, {
      message: 'Password must contain at least one letter and one number.',
    }),
  );
}
