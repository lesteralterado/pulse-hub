import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/profile/data/profile_repository.dart';
import 'package:pulsehub/features/profile/domain/user_profile.dart';

/// In-memory [ProfileRepository] double for widget/provider tests, so
/// nothing in the test suite ever touches a real Supabase project.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({this.result});

  /// Overrides the default success result of the next call.
  Result<UserProfile>? result;

  /// Profiles returned by [searchProfiles], regardless of query.
  List<UserProfile> searchResults = [];
  Result<List<UserProfile>>? searchProfilesResult;

  int getProfileCallCount = 0;
  int searchProfilesCallCount = 0;

  @override
  Future<Result<UserProfile>> getProfile(String userId) async {
    getProfileCallCount++;
    return result ??
        Result.success(
          UserProfile(
            id: userId,
            username: 'testuser',
            fullName: null,
            avatarUrl: null,
            bio: null,
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        );
  }

  @override
  Future<Result<List<UserProfile>>> searchProfiles(String query) async {
    searchProfilesCallCount++;
    return searchProfilesResult ?? Result.success(searchResults);
  }
}
