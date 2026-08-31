import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';

void main() {
  group('Result', () {
    test('success fold returns the success branch', () {
      const result = Result<int>.success(42);

      final message = result.fold((failure) => 'failure', (data) => 'success:$data');

      expect(message, 'success:42');
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, 42);
    });

    test('failure fold returns the failure branch', () {
      const result = Result<int>.failure(NetworkFailure());

      final message = result.fold((failure) => 'failure:${failure.runtimeType}', (data) => 'success');

      expect(message, 'failure:NetworkFailure');
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
    });
  });
}
