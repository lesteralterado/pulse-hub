/// A comment on a post, with the author's display info embedded via
/// PostgREST (`select=*,profiles(username,full_name,avatar_url)`).
class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.authorUsername,
    required this.authorFullName,
    required this.authorAvatarUrl,
  });

  final String id;
  final String postId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final String? authorUsername;
  final String? authorFullName;
  final String? authorAvatarUrl;

  String get authorDisplayName =>
      (authorFullName?.isNotEmpty ?? false) ? authorFullName! : (authorUsername ?? 'Someone');

  factory Comment.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'] as Map<String, dynamic>?;
    return Comment(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      authorId: map['author_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      authorUsername: profile?['username'] as String?,
      authorFullName: profile?['full_name'] as String?,
      authorAvatarUrl: profile?['avatar_url'] as String?,
    );
  }
}
