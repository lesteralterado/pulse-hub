import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../services/auth/auth_service.dart';
import '../../../services/auth/supabase_auth_service.dart';
import '../domain/app_user.dart';

/// Overridden with a fake in tests to avoid touching a real Supabase
/// project. Production code gets [SupabaseAuthService].
final authServiceProvider = Provider<AuthService>((ref) {
  return SupabaseAuthService();
});

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Convenience sync accessor for the current user, derived from
/// [authStateChangesProvider]'s latest value.
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateChangesProvider).value;
});

/// Drives the async submit state (idle/loading/error) for the auth forms.
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> signUp({required String email, required String password}) {
    return _run(() => ref.read(authServiceProvider).signUp(
          email: email,
          password: password,
        ));
  }

  Future<bool> signIn({required String email, required String password}) {
    return _run(() => ref.read(authServiceProvider).signIn(
          email: email,
          password: password,
        ));
  }

  Future<bool> sendPasswordResetEmail(String email) {
    return _run(() => ref.read(authServiceProvider).sendPasswordResetEmail(email));
  }

  Future<bool> resendEmailVerification(String email) {
    return _run(() => ref.read(authServiceProvider).resendEmailVerification(email));
  }

  Future<bool> signOut() {
    return _run(() => ref.read(authServiceProvider).signOut());
  }

  /// Clears any stale loading/error state left over from a previous form.
  /// [AuthController] is shared by all four auth screens, so each one calls
  /// this in `initState` — otherwise a failed login's error banner would
  /// still be showing after navigating to, say, the sign-up screen.
  void reset() => state = const AsyncData(null);

  Future<bool> _run<T>(Future<Result<T>> Function() action) async {
    state = const AsyncLoading();
    final result = await action();
    return result.when(
      success: (_) {
        state = const AsyncData(null);
        return true;
      },
      failure: (error) {
        state = AsyncError(error, StackTrace.current);
        return false;
      },
    );
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
