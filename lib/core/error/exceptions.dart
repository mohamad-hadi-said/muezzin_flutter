class CacheException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const CacheException(this.message, [this.stackTrace]);

  @override
  String toString() => 'CacheException: $message';
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final StackTrace? stackTrace;

  const ServerException(this.message, {this.statusCode, this.stackTrace});

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const NetworkException(this.message, [this.stackTrace]);

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const ValidationException(this.message, [this.stackTrace]);

  @override
  String toString() => 'ValidationException: $message';
}

class UnauthorizedException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const UnauthorizedException([this.message = 'Unauthorized', this.stackTrace]);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class NotFoundException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const NotFoundException([this.message = 'Resource not found', this.stackTrace]);

  @override
  String toString() => 'NotFoundException: $message';
}

class TimeoutException implements Exception {
  final String message;
  final Duration? timeout;
  final StackTrace? stackTrace;

  const TimeoutException(this.message, {this.timeout, this.stackTrace});

  @override
  String toString() => 'TimeoutException: $message';
}
