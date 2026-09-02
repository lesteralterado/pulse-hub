import '../../../core/errors/result.dart';
import '../domain/user_profile.dart';

/// Kept as an interface (implemented by [SupabaseProfileRepository]) so
/// widget/provider tests can substitute a fake instead of hitting a real
/// Supabase project — same reasoning as [AuthService].
abstract class ProfileRepository {
  Future<Result<UserProfile>> getProfile(String userId);
}
