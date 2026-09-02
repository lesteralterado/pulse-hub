import '../errors/app_exception.dart';

/// Turns a caught error into copy that's safe to show a user. [AppException]
/// messages are already human-readable; anything else gets a generic
/// fallback rather than leaking a raw stack/exception string.
String describeError(Object error) {
  if (error is AppException) return error.message;
  return 'Something went wrong. Please try again.';
}
