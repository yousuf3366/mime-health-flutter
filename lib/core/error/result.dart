import 'exceptions.dart';

/// Functional result wrapper used across repositories and use cases.
///
/// Repositories **must not throw**; they always return [Result].
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        Failure<T>() => null,
      };

  AppException? get errorOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final error) => error,
      };

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      Failure<T>(:final error) => failure(error),
    };
  }

  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T>(:final data) => Success(transform(data)),
      Failure<T>(:final error) => Failure(error),
    };
  }
}

/// Successful result carrying [data].
final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

/// Failed result carrying a typed [error].
final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppException error;
}
