import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/chat/domain/message.dart';

void main() {
  group('Message.fromMap', () {
    test('parses a raw messages table row', () {
      final message = Message.fromMap({
        'id': 'm1',
        'conversation_id': 'c1',
        'sender_id': 'u1',
        'content': 'hello',
        'created_at': '2026-01-01T00:00:00Z',
      });

      expect(message.id, 'm1');
      expect(message.conversationId, 'c1');
      expect(message.senderId, 'u1');
      expect(message.content, 'hello');
    });
  });
}
