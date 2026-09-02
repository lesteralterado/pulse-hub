import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import '../../features/auth/domain/app_user.dart';
import '../supabase/supabase_service.dart';
import 'auth_service.dart';

/// [AuthService] backed by Supabase Auth (gotrue).
class SupabaseAuthService implements AuthService {
  supabase.GoTrueClient get _auth => SupabaseService.client.auth;

  @override
  Stream<AppUser?> get authStateChanges =>
      _auth.onAuthStateChange.map((state) => _toAppUser(state.session?.user));

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signUp(email: email, password: password);
      final user = _toAppUser(response.user);
      if (user == null) {
        return const Result.failure(
          UnknownException('Sign up did not return a user'),
        );
      }
      return Result.success(user);
    } catch (error) {
      return Result.failure(mapAuthError(error));
    }
  }

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = _toAppUser(response.user);
      if (user == null) {
        return const Result.failure(
          UnknownException('Sign in did not return a user'),
        );
      }
      return Result.success(user);
    } catch (error) {
      return Result.failure(mapAuthError(error));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapAuthError(error));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapAuthError(error));
    }
  }

  @override
  Future<Result<void>> resendEmailVerification(String email) async {
    try {
      await _auth.resend(email: email, type: supabase.OtpType.signup);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapAuthError(error));
    }
  }

  static AppUser? _toAppUser(supabase.User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      isEmailVerified: user.emailConfirmedAt != null,
    );
  }

  /// Extracted as a standalone function so error-mapping can be unit tested
  /// without needing a live Supabase connection.
  static AppException mapAuthError(Object error) {
    if (error is supabase.AuthException) {
      return AuthException(error.message, cause: error);
    }
    return UnknownException('Unexpected auth error: $error', cause: error);
  }
}
