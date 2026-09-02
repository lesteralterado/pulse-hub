import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/community/domain/comment.dart';

void main() {
  group('Comment.fromMap', () {
    test('parses fields and embedded author profile', () {
      final comment = Comment.fromMap({
        'id': 'c1',
        'post_id': 'p1',
        'author_id': 'u1',
        'content': 'nice post',
        'created_at': '2026-01-01T00:00:00Z',
        'profiles': {
          'username': 'bob',
          'full_name': 'Bob Jones',
          'avatar_url': null,
        },
      });

      expect(comment.id, 'c1');
      expect(comment.postId, 'p1');
      expect(comment.content, 'nice post');
      expect(comment.authorDisplayName, 'Bob Jones');
    });

    test('handles a missing embedded profile gracefully', () {
      final comment = Comment.fromMap({
        'id': 'c1',
        'post_id': 'p1',
        'author_id': 'u1',
        'content': 'nice post',
        'created_at': '2026-01-01T00:00:00Z',
        'profiles': null,
      });

      expect(comment.authorDisplayName, 'Someone');
    });
  });
}
