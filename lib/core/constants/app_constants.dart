/// App-wide constants that don't belong to any single feature.
abstract final class AppConstants {
  static const String appName = 'PulseHub';

  /// Route paths, kept as constants so features and the router agree on
  /// spelling instead of passing raw strings around.
  static const String routeRoot = '/';
  static const String routeLogin = '/login';
  static const String routeSignUp = '/sign-up';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeVerifyEmail = '/verify-email';
}
