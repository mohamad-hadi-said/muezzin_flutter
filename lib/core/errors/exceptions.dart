/// Base class for all app-specific exceptions
abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);

  @override
  String toString() => message;
}

/// Thrown when there's an error communicating with the server
class ServerException extends AppException {
  const ServerException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Thrown when there's a cache-related error
class CacheException extends AppException {
  const CacheException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Thrown when there's a network connectivity issue
class NetworkException extends AppException {
  const NetworkException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Thrown when there's an authentication/authorization error
class AuthException extends AppException {
  const AuthException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Thrown when a requested resource is not found
class NotFoundException extends AppException {
  const NotFoundException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Thrown when there's a validation error
class ValidationException extends AppException {
  final Map<String, List<String>> errors;

  const ValidationException(
    this.errors, [
    String message = 'Validation failed',
    StackTrace? stackTrace,
  ]) : super(message, stackTrace);

  @override
  String toString() => '$message: $errors';
}
