import '../../core/errors/result.dart';
import '../../features/auth/domain/app_user.dart';

/// Auth operations the rest of the app depends on. Kept as an interface
/// (implemented by [SupabaseAuthService] in production) so widget/provider
/// tests can substitute a fake instead of hitting a real Supabase project.
abstract class AuthService {
  Stream<AppUser?> get authStateChanges;

  AppUser? get currentUser;

  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> resendEmailVerification(String email);
}
