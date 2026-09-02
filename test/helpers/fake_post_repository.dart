import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/community/data/post_repository.dart';
import 'package:pulsehub/features/community/domain/comment.dart';
import 'package:pulsehub/features/community/domain/post.dart';

/// In-memory [PostRepository] double for widget/provider tests, so
/// nothing in the test suite ever touches a real Supabase project.
class FakePostRepository implements PostRepository {
  List<Post> feed = [];
  Map<String, List<Comment>> commentsByPost = {};

  Result<List<Post>>? getFeedResult;
  Result<void>? createPostResult;
  Result<void>? updatePostResult;
  Result<void>? deletePostResult;
  Result<List<Comment>>? getCommentsResult;
  Result<void>? addCommentResult;
  Result<void>? deleteCommentResult;
  Result<void>? setLikedResult;
  Result<void>? reportPostResult;

  int createPostCallCount = 0;
  int updatePostCallCount = 0;
  int deletePostCallCount = 0;
  int addCommentCallCount = 0;
  int deleteCommentCallCount = 0;
  int setLikedCallCount = 0;
  int reportPostCallCount = 0;

  @override
  Future<Result<List<Post>>> getFeed({String? groupId}) async {
    return getFeedResult ??
        Result.success(feed.where((p) => p.groupId == groupId).toList());
  }

  @override
  Future<Result<void>> createPost({
    required String content,
    String? groupId,
  }) async {
    createPostCallCount++;
    return createPostResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> updatePost({
    required String postId,
    required String content,
  }) async {
    updatePostCallCount++;
    return updatePostResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> deletePost(String postId) async {
    deletePostCallCount++;
    return deletePostResult ?? const Result.success(null);
  }

  @override
  Future<Result<List<Comment>>> getComments(String postId) async {
    return getCommentsResult ?? Result.success(commentsByPost[postId] ?? []);
  }

  @override
  Future<Result<void>> addComment({
    required String postId,
    required String content,
  }) async {
    addCommentCallCount++;
    return addCommentResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    deleteCommentCallCount++;
    return deleteCommentResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> setLiked({
    required String postId,
    required bool liked,
  }) async {
    setLikedCallCount++;
    return setLikedResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> reportPost({
    required String postId,
    required String reason,
  }) async {
    reportPostCallCount++;
    return reportPostResult ?? const Result.success(null);
  }
}
