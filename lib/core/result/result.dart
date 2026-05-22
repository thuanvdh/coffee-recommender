import 'package:coffee_recommender/core/result/app_failure.dart';

sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(AppFailure failure) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => null,
      };

  AppFailure? get failureOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final failure) => failure,
      };

  Result<R> map<R>(R Function(T value) mapper) {
    return switch (this) {
      Success<T>(:final value) => Result<R>.success(mapper(value)),
      Failure<T>(:final failure) => Result<R>.failure(failure),
    };
  }
}

class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final AppFailure failure;

  const Failure(this.failure);
}
