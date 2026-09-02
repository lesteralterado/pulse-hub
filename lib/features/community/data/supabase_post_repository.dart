import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../services/supabase/supabase_service.dart';
import '../domain/comment.dart';
import '../domain/post.dart';
import 'post_repository.dart';

class SupabasePostRepository implements PostRepository {
  String get _requireUserId {
    final id = SupabaseService.client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('SupabasePostRepository used while signed out');
    }
    return id;
  }

  @override
  Future<Result<List<Post>>> getFeed({String? groupId}) async {
    try {
      var query = SupabaseService.client.from('post_feed').select();
      query = groupId == null
          ? query.isFilter('group_id', null)
          : query.eq('group_id', groupId);
      final rows = await query.order('created_at');
      return Result.success(rows.map(Post.fromMap).toList());
    } catch (error) {
      return Result.failure(mapCommunityError(error));
    }
  }

  @override
  Future<Result<void>> createPost({
    required String content,
    String? groupId,
  }) async {
    try {
      final values = <String, dynamic>{
        'author_id': _requireUserId,
        'content': content,
      };
      if (groupId != null) {
        values['group_id'] = groupId;
      }
      await SupabaseService.client.from('posts').insert(values);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapCommunityError(error));
    }
  }

  @override
  Future<Result<void>> updatePost({
    required String postId,
    required String content,
  }) async {
    try {
      await SupabaseService.client
          .from('posts')
          .update({'content': content}).eq('id', postId);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapCommunityError(error));
    }
  }

  @override
  Future<Result<void>> deletePost(String postId) async {
    try {
      await SupabaseService.client.from('posts').delete().eq('id', postId);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapCommunityError(error));
    }
  }

  @override
  Future<Result<List<Comment>>> getComments(String postId) async {
    try {
      final rows = await SupabaseService.client
          .from('comments')
          .select('*, profiles(username, full_name, avatar_url)')
          .eq('post_id', postId)
          .order('created_at', ascending: true);
      return Result.success(rows.map(Comment.fromMap).toList());
    } catch (error) {
      return Result.failure(mapCommunityError(error));
    }
  }

  @override
  Future<Result<void>> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      await SupabaseService.client.from('comments').insert({
        'post_id': postId,
        'author_id': _requireUserId,
        'content': content,
      });
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapCommunityError(error));
    }
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    try {
      await SupabaseService.client.from('comments').delete().eq('id', commentId);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapCommunityError(error));
    }
  }

  @override
  Future<Result<void>> setLiked({
    required String postId,
    required bool liked,
  }) async {
    try {
      final userId = _requireUserId;
      if (liked) {
        await SupabaseService.client.from('reactions').upsert(
          {'post_id': postId, 'user_id': userId, 'reaction_type': 'like'},
          onConflict: 'post_id,user_id',
          ignoreDuplicates: true,
        );
      } else {
        await SupabaseService.client
            .from('reactions')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);
      }
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapCommunityError(error));
    }
  }

  @override
  Future<Result<void>> reportPost({
    required String postId,
    required String reason,
  }) async {
    try {
      await SupabaseService.client.from('reports').insert({
        'post_id': postId,
        'reporter_id': _requireUserId,
        'reason': reason,
      });
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapCommunityError(error));
    }
  }

  /// Extracted as a standalone function so error-mapping can be unit
  /// tested without needing a live Supabase connection.
  static AppException mapCommunityError(Object error) {
    if (error is supabase.PostgrestException) {
      return ServerException(error.message, cause: error);
    }
    return UnknownException('Unexpected community error: $error', cause: error);
  }
}
