/// A row from the `post_feed` view (see
/// supabase/migrations/0002_community.sql), which already joins author
/// info and aggregate like/comment counts server-side.
class Post {
  const Post({
    required this.id,
    required this.authorId,
    required this.groupId,
    required this.postType,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.authorUsername,
    required this.authorFullName,
    required this.authorAvatarUrl,
    required this.likeCount,
    required this.commentCount,
    required this.likedByMe,
  });

  final String id;
  final String authorId;
  final String? groupId;
  final String postType;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? authorUsername;
  final String? authorFullName;
  final String? authorAvatarUrl;
  final int likeCount;
  final int commentCount;
  final bool likedByMe;

  String get authorDisplayName =>
      (authorFullName?.isNotEmpty ?? false) ? authorFullName! : (authorUsername ?? 'Someone');

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String,
      authorId: map['author_id'] as String,
      groupId: map['group_id'] as String?,
      postType: map['post_type'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      authorUsername: map['author_username'] as String?,
      authorFullName: map['author_full_name'] as String?,
      authorAvatarUrl: map['author_avatar_url'] as String?,
      likeCount: map['like_count'] as int,
      commentCount: map['comment_count'] as int,
      likedByMe: map['liked_by_me'] as bool,
    );
  }
}
