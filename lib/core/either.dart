/// Functional Either type for error handling
library;

import 'errors.dart';

/// Represents a value of one of two possible types (a disjoint union).
/// An instance of Either is either a Left (failure) or Right (success).
sealed class Either<L, R> {
  const Either();

  /// Creates a Left (failure) value
  const factory Either.left(L value) = Left<L, R>;

  /// Creates a Right (success) value
  const factory Either.right(R value) = Right<L, R>;

  /// Returns true if this is a Right value
  bool get isRight => this is Right<L, R>;

  /// Returns true if this is a Left value
  bool get isLeft => this is Left<L, R>;

  /// Fold the either into a value
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight);

  /// Map the right value
  Either<L, T> map<T>(T Function(R right) mapper);

  /// FlatMap the right value
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) mapper);

  /// Get the right value or throw
  R get value;

  /// Get the right value or return a default
  R getOrElse(R Function() defaultValue);

  /// Get the left value or null
  L? get leftOrNull;

  /// Get the right value or null
  R? get rightOrNull;
}

/// Left value (failure)
final class Left<L, R> extends Either<L, R> {
  final L _value;

  const Left(this._value);

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onLeft(_value);
  }

  @override
  Either<L, T> map<T>(T Function(R right) mapper) {
    return Left(_value);
  }

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) mapper) {
    return Left(_value);
  }

  @override
  R get value => throw Exception('Called value on Left: $_value');

  @override
  R getOrElse(R Function() defaultValue) => defaultValue();

  @override
  L? get leftOrNull => _value;

  @override
  R? get rightOrNull => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Left<L, R> && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Left($_value)';
}

/// Right value (success)
final class Right<L, R> extends Either<L, R> {
  final R _value;

  const Right(this._value);

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onRight(_value);
  }

  @override
  Either<L, T> map<T>(T Function(R right) mapper) {
    return Right(mapper(_value));
  }

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) mapper) {
    return mapper(_value);
  }

  @override
  R get value => _value;

  @override
  R getOrElse(R Function() defaultValue) => _value;

  @override
  L? get leftOrNull => null;

  @override
  R? get rightOrNull => _value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Right<L, R> && _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Right($_value)';
}

/// Type alias for common Either usage with AppError
typedef Result<T> = Either<AppError, T>;
