/// Base type for all handled errors in PulseHub.
///
/// Feature and service layers should throw one of the concrete subtypes
/// below rather than raw exceptions, so callers can pattern-match on
/// failure kind instead of parsing strings.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

/// Network-level failures: no connection, timeout, DNS, etc.
final class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
}

/// Authentication/authorization failures (bad credentials, expired session).
final class AuthException extends AppException {
  const AuthException(super.message, {super.cause});
}

/// The server responded, but with an error status.
final class ServerException extends AppException {
  const ServerException(super.message, {super.cause, this.statusCode});

  final int? statusCode;
}

/// Local validation failures (bad input before it ever reaches the network).
final class ValidationException extends AppException {
  const ValidationException(super.message, {super.cause});
}

/// Anything that doesn't fit the categories above.
final class UnknownException extends AppException {
  const UnknownException(super.message, {super.cause});
}
