import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/network/api_error_mapper.dart';

void main() {
  const mapper = ApiErrorMapper();
  final requestOptions = RequestOptions(path: '/test');

  test('maps connection timeout to TimeoutFailure', () {
    final error = DioException(requestOptions: requestOptions, type: DioExceptionType.connectionTimeout);
    expect(mapper.map(error), isA<TimeoutFailure>());
  });

  test('maps connection error to NetworkFailure', () {
    final error = DioException(requestOptions: requestOptions, type: DioExceptionType.connectionError);
    expect(mapper.map(error), isA<NetworkFailure>());
  });

  test('maps 401 response to UnauthorizedFailure', () {
    final error = DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: requestOptions, statusCode: 401),
    );
    expect(mapper.map(error), isA<UnauthorizedFailure>());
  });

  test('maps 422 response to ValidationFailure with field errors', () {
    final error = DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: requestOptions,
        statusCode: 422,
        data: {
          'message': 'Validation failed',
          'errors': {
            'email': ['Email is invalid'],
          },
        },
      ),
    );

    final failure = mapper.map(error) as ValidationFailure;
    expect(failure.message, 'Validation failed');
    expect(failure.fieldErrors['email'], ['Email is invalid']);
  });

  test('maps 500 response to ServerFailure with status code', () {
    final error = DioException(
      requestOptions: requestOptions,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: requestOptions, statusCode: 500),
    );

    final failure = mapper.map(error) as ServerFailure;
    expect(failure.statusCode, 500);
  });

  test('passes through an already-typed Failure unchanged', () {
    const failure = ForbiddenFailure();
    expect(mapper.map(failure), same(failure));
  });

  test('maps a non-Dio error to UnknownFailure', () {
    expect(mapper.map(Exception('boom')), isA<UnknownFailure>());
  });

  DioException apiError(int status, {Map<String, dynamic>? body, Map<String, List<String>>? headers}) => DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: requestOptions,
      statusCode: status,
      data: body,
      headers: Headers.fromMap(headers ?? {}),
    ),
  );

  test('reads the error code from the API envelope', () {
    final failure = mapper.map(
      apiError(
        403,
        body: {
          'error': {'message': 'This account is not active.', 'code': 'ACCOUNT_INACTIVE'},
        },
      ),
    );

    expect(failure, isA<ForbiddenFailure>());
    expect(failure.code, ApiErrorCodes.accountInactive);
  });

  test('maps 429 to RateLimitedFailure with the Retry-After delay', () {
    final failure = mapper.map(
      apiError(
        429,
        headers: {
          'retry-after': ['900'],
        },
      ),
    );

    expect(failure, isA<RateLimitedFailure>().having((f) => f.retryAfter, 'retryAfter', const Duration(minutes: 15)));
  });

  test('maps 429 without a usable Retry-After to a RateLimitedFailure with no delay', () {
    final failure = mapper.map(
      apiError(
        429,
        headers: {
          'retry-after': ['Wed, 21 Oct 2026 07:28:00 GMT'],
        },
      ),
    );

    expect(failure, isA<RateLimitedFailure>().having((f) => f.retryAfter, 'retryAfter', isNull));
  });
}
