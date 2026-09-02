import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/sign_up_page.dart';
import '../../features/auth/presentation/verify_email_page.dart';
import '../../features/home/presentation/foundation_status_page.dart';
import '../constants/app_constants.dart';

const _authRoutes = {
  AppConstants.routeLogin,
  AppConstants.routeSignUp,
  AppConstants.routeForgotPassword,
  AppConstants.routeVerifyEmail,
};

/// Built as a provider (rather than a bare static field) so it can react to
/// [authStateChangesProvider] and redirect between the signed-in and
/// signed-out parts of the app.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);

  // ref.listen fires only after authStateChangesProvider's own state has
  // been updated, so by the time `redirect` below re-reads it via
  // ref.read, it's guaranteed to see the new value — no race between the
  // two.
  final subscription = ref.listen(
    authStateChangesProvider,
    (previous, next) => refreshNotifier.notify(),
  );
  ref.onDispose(subscription.close);

  return GoRouter(
    initialLocation: AppConstants.routeRoot,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      if (authState.isLoading) return null;

      final isAuthenticated = authState.value != null;
      final goingToAuthRoute = _authRoutes.contains(state.matchedLocation);

      if (!isAuthenticated && !goingToAuthRoute) {
        return AppConstants.routeLogin;
      }
      if (isAuthenticated && goingToAuthRoute) {
        return AppConstants.routeRoot;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.routeRoot,
        builder: (context, state) => const FoundationStatusPage(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppConstants.routeSignUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppConstants.routeForgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppConstants.routeVerifyEmail,
        builder: (context, state) => VerifyEmailPage(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
    ],
  );
});

/// Plain [Listenable] GoRouter can watch, decoupled from how the
/// notification is triggered (a Riverpod listener, here).
class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
