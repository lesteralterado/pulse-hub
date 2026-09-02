import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/community/domain/post.dart';

Map<String, dynamic> _row({
  String? groupId,
  String? authorUsername = 'alice',
  String? authorFullName,
  int likeCount = 0,
  int commentCount = 0,
  bool likedByMe = false,
}) {
  return {
    'id': 'p1',
    'author_id': 'u1',
    'group_id': groupId,
    'post_type': 'text',
    'content': 'hello world',
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-02T00:00:00Z',
    'author_username': authorUsername,
    'author_full_name': authorFullName,
    'author_avatar_url': null,
    'like_count': likeCount,
    'comment_count': commentCount,
    'liked_by_me': likedByMe,
  };
}

void main() {
  group('Post.fromMap', () {
    test('parses all fields from a post_feed row', () {
      final post = Post.fromMap(
        _row(likeCount: 3, commentCount: 2, likedByMe: true),
      );

      expect(post.id, 'p1');
      expect(post.authorId, 'u1');
      expect(post.groupId, isNull);
      expect(post.content, 'hello world');
      expect(post.likeCount, 3);
      expect(post.commentCount, 2);
      expect(post.likedByMe, isTrue);
    });

    test('a group post carries its group id', () {
      final post = Post.fromMap(_row(groupId: 'g1'));
      expect(post.groupId, 'g1');
    });

    test('authorDisplayName falls back to username when no full name', () {
      final post = Post.fromMap(_row(authorUsername: 'alice', authorFullName: null));
      expect(post.authorDisplayName, 'alice');
    });

    test('authorDisplayName prefers full name over username', () {
      final post = Post.fromMap(
        _row(authorUsername: 'alice', authorFullName: 'Alice Smith'),
      );
      expect(post.authorDisplayName, 'Alice Smith');
    });

    test('authorDisplayName falls back to a generic label with neither', () {
      final post = Post.fromMap(_row(authorUsername: null, authorFullName: null));
      expect(post.authorDisplayName, 'Someone');
    });
  });
}
