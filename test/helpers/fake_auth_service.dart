import 'dart:async';

import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';
import 'package:pulsehub/services/auth/auth_service.dart';

/// In-memory [AuthService] double for widget/provider tests, so nothing in
/// the test suite ever touches a real Supabase project.
class FakeAuthService implements AuthService {
  FakeAuthService({AppUser? initialUser}) : _currentUser = initialUser {
    // `sync: true` + seeding on listen mirrors Supabase's
    // onAuthStateChange, which replays the current session to a new
    // subscriber — without it, StreamProvider/GoRouterRefreshStream would
    // sit in AsyncLoading forever since nothing ever calls emitUser().
    _controller = StreamController<AppUser?>.broadcast(
      sync: true,
      onListen: () => _controller.add(_currentUser),
    );
  }

  late final StreamController<AppUser?> _controller;
  AppUser? _currentUser;

  /// Set to override the default success result of the next matching call.
  Result<AppUser>? signUpResult;
  Result<AppUser>? signInResult;
  Result<void>? signOutResult;
  Result<void>? sendPasswordResetEmailResult;
  Result<void>? resendEmailVerificationResult;

  int signUpCallCount = 0;
  int signInCallCount = 0;
  int signOutCallCount = 0;
  int sendPasswordResetEmailCallCount = 0;
  int resendEmailVerificationCallCount = 0;

  /// Simulates an auth-state change coming from outside the current call
  /// (e.g. another tab signing out).
  void emitUser(AppUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  void dispose() => _controller.close();

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
  }) async {
    signUpCallCount++;
    final result = signUpResult ??
        Result.success(AppUser(id: 'fake-id', email: email, isEmailVerified: false));
    if (result.isSuccess) emitUser(result.valueOrNull);
    return result;
  }

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    signInCallCount++;
    final result = signInResult ??
        Result.success(AppUser(id: 'fake-id', email: email, isEmailVerified: true));
    if (result.isSuccess) emitUser(result.valueOrNull);
    return result;
  }

  @override
  Future<Result<void>> signOut() async {
    signOutCallCount++;
    final result = signOutResult ?? const Result<void>.success(null);
    if (result.isSuccess) emitUser(null);
    return result;
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    sendPasswordResetEmailCallCount++;
    return sendPasswordResetEmailResult ?? const Result<void>.success(null);
  }

  @override
  Future<Result<void>> resendEmailVerification(String email) async {
    resendEmailVerificationCallCount++;
    return resendEmailVerificationResult ?? const Result<void>.success(null);
  }
}
