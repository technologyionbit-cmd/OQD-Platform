import { applyDecorators } from '@nestjs/common';
import { IsString, Matches, MaxLength } from 'class-validator';

/** A person's full name (individual and lawyer accounts). */
export const PERSON_NAME_MAX_LENGTH = 120;
/** A company's name, stored as the company account's full name. */
export const COMPANY_NAME_MAX_LENGTH = 160;

const HAS_VISIBLE_CHARACTER = /\S/;

/**
 * Rules for a display name. The server trims names before storing them,
 * so a value of only spaces must be rejected here, not saved as "".
 */
export function DisplayName(maxLength: number): PropertyDecorator {
  return applyDecorators(
    IsString(),
    MaxLength(maxLength),
    Matches(HAS_VISIBLE_CHARACTER, { message: 'Name must not be blank.' }),
  );
}
