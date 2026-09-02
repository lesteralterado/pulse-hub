import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/meetings/domain/meeting_message.dart';

void main() {
  group('MeetingMessage.fromMap', () {
    test('parses a raw meeting_messages table row', () {
      final message = MeetingMessage.fromMap({
        'id': 'm1',
        'meeting_id': 'mt1',
        'sender_id': 'u1',
        'content': 'hello everyone',
        'created_at': '2026-01-01T00:00:00Z',
      });

      expect(message.id, 'm1');
      expect(message.meetingId, 'mt1');
      expect(message.content, 'hello everyone');
    });
  });
}
