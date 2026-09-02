import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/group_repository.dart';
import '../data/post_repository.dart';
import '../data/supabase_group_repository.dart';
import '../data/supabase_post_repository.dart';
import '../domain/comment.dart';
import '../domain/group.dart';
import '../domain/post.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return SupabasePostRepository();
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return SupabaseGroupRepository();
});

/// The feed for a given group, or the general feed when [groupId] is null.
/// Mutations (create/edit/delete/like) call `ref.invalidate(feedProvider(
/// groupId))` to refetch rather than patching this list in place, keeping
/// counts/ordering authoritative from the server.
final feedProvider =
    FutureProvider.autoDispose.family<List<Post>, String?>((ref, groupId) {
  return ref.watch(postRepositoryProvider).getFeed(groupId: groupId).then(
        (result) => result.when(success: (posts) => posts, failure: (e) => throw e),
      );
});

final commentsProvider =
    FutureProvider.autoDispose.family<List<Comment>, String>((ref, postId) {
  return ref.watch(postRepositoryProvider).getComments(postId).then(
        (result) =>
            result.when(success: (comments) => comments, failure: (e) => throw e),
      );
});

final groupsProvider = FutureProvider.autoDispose<List<Group>>((ref) {
  return ref.watch(groupRepositoryProvider).getGroups().then(
        (result) => result.when(success: (groups) => groups, failure: (e) => throw e),
      );
});
