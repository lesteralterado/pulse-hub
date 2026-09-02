import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/chat/domain/conversation_member.dart';

void main() {
  group('ConversationMember.fromMap', () {
    test('parses fields and the embedded profile', () {
      final member = ConversationMember.fromMap({
        'user_id': 'u1',
        'role': 'owner',
        'joined_at': '2026-01-01T00:00:00Z',
        'profiles': {
          'username': 'alice',
          'full_name': 'Alice Smith',
          'avatar_url': null,
        },
      });

      expect(member.userId, 'u1');
      expect(member.isOwner, isTrue);
      expect(member.displayName, 'Alice Smith');
    });

    test('a member role is not an owner', () {
      final member = ConversationMember.fromMap({
        'user_id': 'u2',
        'role': 'member',
        'joined_at': '2026-01-01T00:00:00Z',
        'profiles': null,
      });

      expect(member.isOwner, isFalse);
      expect(member.displayName, 'Someone');
    });
  });
}
