import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';

/// App-wide retry policy for failed providers (`ProviderScope.retry`).
///
/// Riverpod's default retries every error ten times. A 404, 401 or 422
/// comes back the same on every try, so that only floods the API.
/// Instead only transient failures (no connection, timeout, 5xx) are
/// retried, a few times with backoff; everything else surfaces right away
/// and the screen's retry button or pull-to-refresh takes over.
Duration? providerRetry(int retryCount, Object error) {
  if (!_isTransient(error)) return null;
  return ProviderContainer.defaultRetry(
    retryCount,
    error,
    maxRetries: 3,
    minDelay: const Duration(seconds: 1),
    maxDelay: const Duration(seconds: 4),
  );
}

bool _isTransient(Object error) => switch (error) {
  NetworkFailure() || TimeoutFailure() => true,
  ServerFailure(:final statusCode) => statusCode == null || statusCode >= 500,
  _ => false,
};
