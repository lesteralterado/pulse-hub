import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/meetings/domain/meeting.dart';

Map<String, dynamic> _row({
  String status = 'scheduled',
  required DateTime scheduledStart,
  String? myRsvpStatus,
}) {
  return {
    'id': 'm1',
    'host_id': 'u1',
    'title': 'Weekly sync',
    'description': null,
    'scheduled_start': scheduledStart.toUtc().toIso8601String(),
    'scheduled_end': scheduledStart.add(const Duration(hours: 1)).toUtc().toIso8601String(),
    'status': status,
    'locked': false,
    'created_at': '2026-01-01T00:00:00Z',
    'host_username': 'alice',
    'host_full_name': null,
    'participant_count': 2,
    'my_rsvp_status': myRsvpStatus,
  };
}

void main() {
  group('Meeting.fromMap', () {
    test('parses all fields', () {
      final meeting = Meeting.fromMap(_row(scheduledStart: DateTime.now()));
      expect(meeting.id, 'm1');
      expect(meeting.hostUsername, 'alice');
      expect(meeting.participantCount, 2);
    });

    test('isGoing reflects my_rsvp_status', () {
      final going = Meeting.fromMap(_row(scheduledStart: DateTime.now(), myRsvpStatus: 'going'));
      expect(going.isGoing, isTrue);

      final notGoing = Meeting.fromMap(_row(scheduledStart: DateTime.now()));
      expect(notGoing.isGoing, isFalse);
    });
  });

  group('Meeting.displayStatus', () {
    test('a live meeting reads Live', () {
      final meeting = Meeting.fromMap(_row(status: 'live', scheduledStart: DateTime.now()));
      expect(meeting.displayStatus, 'Live');
    });

    test('a cancelled meeting reads Cancelled', () {
      final meeting = Meeting.fromMap(_row(status: 'cancelled', scheduledStart: DateTime.now()));
      expect(meeting.displayStatus, 'Cancelled');
    });

    test('an ended meeting reads Ended', () {
      final meeting = Meeting.fromMap(_row(status: 'ended', scheduledStart: DateTime.now()));
      expect(meeting.displayStatus, 'Ended');
    });

    test('a scheduled meeting starting within 15 minutes reads Starting soon', () {
      final meeting = Meeting.fromMap(
        _row(
          status: 'scheduled',
          scheduledStart: DateTime.now().add(const Duration(minutes: 5)),
        ),
      );
      expect(meeting.displayStatus, 'Starting soon');
      expect(meeting.isStartingSoon, isTrue);
    });

    test('a scheduled meeting far in the future reads Scheduled', () {
      final meeting = Meeting.fromMap(
        _row(
          status: 'scheduled',
          scheduledStart: DateTime.now().add(const Duration(days: 3)),
        ),
      );
      expect(meeting.displayStatus, 'Scheduled');
      expect(meeting.isStartingSoon, isFalse);
    });

    test('a scheduled meeting whose start time has passed is not "starting soon"', () {
      final meeting = Meeting.fromMap(
        _row(
          status: 'scheduled',
          scheduledStart: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      );
      expect(meeting.isStartingSoon, isFalse);
    });
  });
}
