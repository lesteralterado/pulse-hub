import '../../../core/errors/result.dart';
import '../domain/comment.dart';
import '../domain/post.dart';

/// Kept as an interface (implemented by [SupabasePostRepository]) so
/// widget/provider tests can substitute a fake instead of hitting a real
/// Supabase project — same pattern as [AuthService]/[ProfileRepository].
abstract class PostRepository {
  /// [groupId] null returns the general feed; otherwise a group's feed.
  Future<Result<List<Post>>> getFeed({String? groupId});

  Future<Result<void>> createPost({required String content, String? groupId});

  Future<Result<void>> updatePost({
    required String postId,
    required String content,
  });

  Future<Result<void>> deletePost(String postId);

  Future<Result<List<Comment>>> getComments(String postId);

  Future<Result<void>> addComment({
    required String postId,
    required String content,
  });

  Future<Result<void>> deleteComment(String commentId);

  Future<Result<void>> setLiked({required String postId, required bool liked});

  Future<Result<void>> reportPost({
    required String postId,
    required String reason,
  });
}
