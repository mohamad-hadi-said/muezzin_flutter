import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];

  @override
  String toString() => 'Failure: $message';
}

class CacheFailure extends Failure {
  const CacheFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(String message, {this.statusCode, StackTrace? stackTrace})
      : super(message, stackTrace);

  @override
  List<Object?> get props => [message, statusCode, stackTrace];
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class UnexpectedFailure extends Failure {
  final dynamic error;

  const UnexpectedFailure(this.error, [StackTrace? stackTrace])
      : super('An unexpected error occurred', stackTrace);

  @override
  List<Object?> get props => [error, stackTrace];
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}
