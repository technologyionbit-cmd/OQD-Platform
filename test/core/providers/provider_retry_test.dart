import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/providers/provider_retry.dart';

void main() {
  group('providerRetry', () {
    test('retries transient failures with a growing delay', () {
      expect(providerRetry(0, const NetworkFailure()), const Duration(seconds: 1));
      expect(providerRetry(1, const TimeoutFailure()), const Duration(seconds: 2));
      expect(providerRetry(2, const ServerFailure(statusCode: 503)), const Duration(seconds: 4));
      expect(providerRetry(0, const ServerFailure()), isNotNull);
    });

    test('stops after three retries', () {
      expect(providerRetry(3, const NetworkFailure()), isNull);
    });

    test('never retries failures that would come back the same', () {
      for (final failure in const <Failure>[
        NotFoundFailure(),
        UnauthorizedFailure(),
        ForbiddenFailure(),
        ValidationFailure(),
        RateLimitedFailure(),
        ServerFailure(statusCode: 409),
        UnknownFailure(),
      ]) {
        expect(providerRetry(0, failure), isNull, reason: failure.runtimeType.toString());
      }
    });

    test('never retries non-failure errors', () {
      expect(providerRetry(0, StateError('bug')), isNull);
      expect(providerRetry(0, Exception('unexpected')), isNull);
    });
  });
}
