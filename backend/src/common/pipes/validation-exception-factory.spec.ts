import { UnprocessableEntityException } from '@nestjs/common';
import type { ValidationError } from '@nestjs/common';
import { validationExceptionFactory } from './validation-exception-factory';

describe('validationExceptionFactory', () => {
  it('shapes a single-field constraint violation into the error envelope', () => {
    const errors: ValidationError[] = [
      {
        property: 'email',
        constraints: { isEmail: 'email must be an email' },
      },
    ];

    const exception = validationExceptionFactory(errors);

    expect(exception).toBeInstanceOf(UnprocessableEntityException);
    expect(exception.getStatus()).toBe(422);
    expect(exception.getResponse()).toEqual({
      message: 'Validation failed',
      code: 'VALIDATION_ERROR',
      errors: { email: ['email must be an email'] },
    });
  });

  it('flattens nested validation errors using dotted paths', () => {
    const errors: ValidationError[] = [
      {
        property: 'address',
        children: [
          {
            property: 'city',
            constraints: { isNotEmpty: 'city should not be empty' },
          },
        ],
      },
    ];

    const exception = validationExceptionFactory(errors);

    expect(exception.getResponse()).toMatchObject({
      errors: { 'address.city': ['city should not be empty'] },
    });
  });

  it('produces an empty errors map when given no validation errors', () => {
    const exception = validationExceptionFactory([]);

    expect(exception.getResponse()).toEqual({
      message: 'Validation failed',
      code: 'VALIDATION_ERROR',
      errors: {},
    });
  });
});
