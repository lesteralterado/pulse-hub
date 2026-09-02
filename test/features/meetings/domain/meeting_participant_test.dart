import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/meetings/domain/meeting_participant.dart';

void main() {
  group('MeetingParticipant.fromMap', () {
    test('parses fields and the embedded profile', () {
      final participant = MeetingParticipant.fromMap({
        'user_id': 'u1',
        'role': 'host',
        'rsvp_status': 'going',
        'joined_at': null,
        'profiles': {'username': 'alice', 'full_name': 'Alice Smith', 'avatar_url': null},
      });

      expect(participant.isHost, isTrue);
      expect(participant.isCoHost, isFalse);
      expect(participant.displayName, 'Alice Smith');
    });

    test('a participant role is neither host nor co-host', () {
      final participant = MeetingParticipant.fromMap({
        'user_id': 'u2',
        'role': 'participant',
        'rsvp_status': 'going',
        'joined_at': '2026-01-01T00:00:00Z',
        'profiles': null,
      });

      expect(participant.isHost, isFalse);
      expect(participant.isCoHost, isFalse);
      expect(participant.displayName, 'Someone');
      expect(participant.joinedAt, isNotNull);
    });
  });
}
