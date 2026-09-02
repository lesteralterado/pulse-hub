import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../services/supabase/supabase_service.dart';
import '../domain/user_profile.dart';
import 'profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  @override
  Future<Result<UserProfile>> getProfile(String userId) async {
    try {
      final row = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (row == null) {
        return const Result.failure(
          UnknownException('No profile found for this account'),
        );
      }
      return Result.success(UserProfile.fromMap(row));
    } catch (error) {
      return Result.failure(mapProfileError(error));
    }
  }

  @override
  Future<Result<List<UserProfile>>> searchProfiles(String query) async {
    try {
      final rows = await SupabaseService.client
          .from('profiles')
          .select()
          .ilike('username', '%$query%')
          .limit(20);
      return Result.success(rows.map(UserProfile.fromMap).toList());
    } catch (error) {
      return Result.failure(mapProfileError(error));
    }
  }

  /// Extracted as a standalone function so error-mapping can be unit
  /// tested without needing a live Supabase connection.
  static AppException mapProfileError(Object error) {
    if (error is supabase.PostgrestException) {
      return ServerException(error.message, cause: error);
    }
    return UnknownException('Unexpected profile error: $error', cause: error);
  }
}
