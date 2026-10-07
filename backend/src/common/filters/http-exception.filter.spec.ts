import {
  ArgumentsHost,
  BadRequestException,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { RateLimitedException } from '../errors/rate-limited.exception';
import { HttpExceptionFilter } from './http-exception.filter';

function createMockHost(overrides?: { method?: string; url?: string }) {
  const json = jest.fn();
  const status = jest.fn().mockReturnValue({ json });
  const header = jest.fn();
  const response = { status, header };
  const request = {
    method: overrides?.method ?? 'GET',
    url: overrides?.url ?? '/v1/test',
  };

  const host = {
    switchToHttp: () => ({
      getResponse: () => response,
      getRequest: () => request,
    }),
  } as unknown as ArgumentsHost;

  return { host, status, json, header };
}

describe('HttpExceptionFilter', () => {
  let filter: HttpExceptionFilter;

  beforeEach(() => {
    filter = new HttpExceptionFilter();
  });

  it('maps a plain HttpException to the error envelope with a derived code', () => {
    const { host, status, json } = createMockHost();

    filter.catch(new HttpException('Not found', HttpStatus.NOT_FOUND), host);

    expect(status).toHaveBeenCalledWith(404);
    expect(json).toHaveBeenCalledWith({
      error: { message: 'Not found', code: 'NOT_FOUND' },
    });
  });

  it('preserves a custom code/errors payload already on the exception response', () => {
    const { host, status, json } = createMockHost();

    filter.catch(
      new BadRequestException({
        message: 'Validation failed',
        code: 'VALIDATION_ERROR',
        errors: { email: ['already in use'] },
      }),
      host,
    );

    expect(status).toHaveBeenCalledWith(400);
    expect(json).toHaveBeenCalledWith({
      error: {
        message: 'Validation failed',
        code: 'VALIDATION_ERROR',
        errors: { email: ['already in use'] },
      },
    });
  });

  it('sends Retry-After (whole seconds, at least 1) for a RateLimitedException', () => {
    const { host, status, json, header } = createMockHost();

    filter.catch(new RateLimitedException('Slow down.', 41.2), host);

    expect(status).toHaveBeenCalledWith(429);
    expect(header).toHaveBeenCalledWith('Retry-After', '42');
    expect(json).toHaveBeenCalledWith({
      error: { message: 'Slow down.', code: 'TOO_MANY_REQUESTS' },
    });
  });

  it('never leaks internal error details for an unknown/unhandled exception', () => {
    const { host, status, json } = createMockHost();

    filter.catch(new Error('db password is hunter2'), host);

    expect(status).toHaveBeenCalledWith(500);
    expect(json).toHaveBeenCalledWith({
      error: {
        message: 'An unexpected error occurred.',
        code: 'SERVER_ERROR',
      },
    });
  });
});
