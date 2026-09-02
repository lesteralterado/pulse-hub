import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/profile_repository.dart';
import '../data/supabase_profile_repository.dart';
import '../domain/user_profile.dart';

/// Overridden with a fake in tests to avoid touching a real Supabase
/// project. Production code gets [SupabaseProfileRepository].
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return SupabaseProfileRepository();
});

/// The signed-in user's own profile row. Re-fetches whenever the signed-in
/// user changes (including on sign-out, where reading it is a programmer
/// error rather than a state to render around, since the UI that watches
/// this is only ever shown while authenticated).
final myProfileProvider = FutureProvider<UserProfile>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw StateError('myProfileProvider was read while signed out');
  }

  final result = await ref.watch(profileRepositoryProvider).getProfile(user.id);
  return result.when(
    success: (profile) => profile,
    failure: (error) => throw error,
  );
});

/// Any user's profile by id — used when viewing a post/comment author from
/// the community feed, distinct from [myProfileProvider] which is always
/// the signed-in user's own.
final profileByIdProvider =
    FutureProvider.autoDispose.family<UserProfile, String>((ref, userId) async {
  final result = await ref.watch(profileRepositoryProvider).getProfile(userId);
  return result.when(
    success: (profile) => profile,
    failure: (error) => throw error,
  );
});
