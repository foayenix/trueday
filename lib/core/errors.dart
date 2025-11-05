/// Application error types
library;

/// Base error class for the application
sealed class AppError implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppError(this.message, [this.stackTrace]);

  @override
  String toString() => 'AppError: $message';
}

/// Database related errors
final class DatabaseError extends AppError {
  const DatabaseError(super.message, [super.stackTrace]);

  @override
  String toString() => 'DatabaseError: $message';
}

/// Parsing errors
final class ParseError extends AppError {
  final String input;

  const ParseError(super.message, this.input, [super.stackTrace]);

  @override
  String toString() => 'ParseError: $message (input: "$input")';
}

/// Validation errors
final class ValidationError extends AppError {
  final String field;

  const ValidationError(super.message, this.field, [super.stackTrace]);

  @override
  String toString() => 'ValidationError: $message (field: $field)';
}

/// Schedule/Reflow errors
final class ScheduleError extends AppError {
  const ScheduleError(super.message, [super.stackTrace]);

  @override
  String toString() => 'ScheduleError: $message';
}

/// Not found errors
final class NotFoundError extends AppError {
  final String resourceType;
  final String resourceId;

  const NotFoundError(this.resourceType, this.resourceId, [StackTrace? stackTrace])
      : super('$resourceType not found: $resourceId', stackTrace);

  @override
  String toString() => 'NotFoundError: $resourceType not found: $resourceId';
}

/// Permission errors
final class PermissionError extends AppError {
  final String permission;

  const PermissionError(super.message, this.permission, [super.stackTrace]);

  @override
  String toString() => 'PermissionError: $message (permission: $permission)';
}

/// Unknown/Generic errors
final class UnknownError extends AppError {
  final Object? originalError;

  const UnknownError(super.message, [this.originalError, super.stackTrace]);

  @override
  String toString() => 'UnknownError: $message${originalError != null ? ' ($originalError)' : ''}';
}
