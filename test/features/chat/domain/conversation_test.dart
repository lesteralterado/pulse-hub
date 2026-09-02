import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/chat/domain/conversation.dart';

Map<String, dynamic> _row({
  bool isGroup = false,
  String? name,
  String? otherUsername,
  String? otherFullName,
  int unreadCount = 0,
}) {
  return {
    'id': 'c1',
    'is_group': isGroup,
    'name': name,
    'created_by': 'u1',
    'created_at': '2026-01-01T00:00:00Z',
    'last_read_at': null,
    'last_message_content': 'hi',
    'last_message_at': '2026-01-02T00:00:00Z',
    'last_message_sender_id': 'u2',
    'unread_count': unreadCount,
    'other_member_username': otherUsername,
    'other_member_full_name': otherFullName,
    'other_member_avatar_url': null,
  };
}

void main() {
  group('Conversation.fromMap', () {
    test('parses all fields', () {
      final conversation = Conversation.fromMap(_row(unreadCount: 3));

      expect(conversation.id, 'c1');
      expect(conversation.unreadCount, 3);
      expect(conversation.lastMessageContent, 'hi');
    });

    test('group displayName uses the group name', () {
      final conversation = Conversation.fromMap(_row(isGroup: true, name: 'BOT Chain Fans'));
      expect(conversation.displayName, 'BOT Chain Fans');
    });

    test('a nameless group falls back to a generic label', () {
      final conversation = Conversation.fromMap(_row(isGroup: true, name: null));
      expect(conversation.displayName, 'Group chat');
    });

    test('a 1:1 chat displayName prefers the other member\'s full name', () {
      final conversation = Conversation.fromMap(
        _row(otherUsername: 'bob', otherFullName: 'Bob Jones'),
      );
      expect(conversation.displayName, 'Bob Jones');
    });

    test('a 1:1 chat falls back to username, then a generic label', () {
      final withUsername = Conversation.fromMap(_row(otherUsername: 'bob'));
      expect(withUsername.displayName, 'bob');

      final withNeither = Conversation.fromMap(_row());
      expect(withNeither.displayName, 'Direct message');
    });
  });
}
