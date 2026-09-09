import { UnprocessableEntityException } from '@nestjs/common';
import type { ValidationError } from '@nestjs/common';
import { ApiErrorCode } from '../errors/api-error-codes';

/**
 * Shapes class-validator failures into the 422 ValidationFailure the
 * frontend expects (docs/backend/05-api-design.md §4): one entry per
 * field, each a list of human-readable constraint messages.
 */
export function validationExceptionFactory(
  validationErrors: ValidationError[],
): UnprocessableEntityException {
  const errors: Record<string, string[]> = {};

  const flatten = (error: ValidationError, path: string): void => {
    const fieldPath = path ? `${path}.${error.property}` : error.property;
    if (error.constraints) {
      errors[fieldPath] = Object.values(error.constraints);
    }
    error.children?.forEach((child) => flatten(child, fieldPath));
  };

  validationErrors.forEach((error) => flatten(error, ''));

  return new UnprocessableEntityException({
    message: 'Validation failed',
    code: ApiErrorCode.VALIDATION_ERROR,
    errors,
  });
}
