import 'package:aqd_ionbit/core/errors/failure.dart';

/// Outcome of a repository operation: either a value or a [Failure].
///
/// Repositories return this instead of throwing, so every call site is
/// forced to handle failure explicitly rather than relying on try/catch
/// leaking implementation-specific exceptions into the domain/presentation
/// layers.
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = ResultFailure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultFailure<T>;

  /// Pattern-matches on the result, mirroring `switch` but usable as an
  /// expression at call sites that just want the resulting value.
  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      ResultFailure<T>(:final failure) => onFailure(failure),
    };
  }

  /// Returns the success value, or `null` if this is a failure.
  T? get valueOrNull => switch (this) {
    Success<T>(:final data) => data,
    ResultFailure<T>() => null,
  };
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);
  final Failure failure;
}
