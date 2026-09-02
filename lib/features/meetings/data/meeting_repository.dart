import '../../../core/errors/result.dart';
import '../domain/meeting.dart';
import '../domain/meeting_message.dart';
import '../domain/meeting_participant.dart';

/// Kept as an interface (implemented by [SupabaseMeetingRepository]) so
/// widget/provider tests can substitute a fake instead of hitting a real
/// Supabase project — same pattern as the other repositories.
abstract class MeetingRepository {
  Future<Result<List<Meeting>>> getMeetings();

  Future<Result<void>> createMeeting({
    required String title,
    String? description,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
  });

  Future<Result<List<MeetingParticipant>>> getParticipants(String meetingId);

  Future<Result<void>> rsvp(String meetingId);

  Future<Result<void>> cancelRsvp(String meetingId);

  /// Records that the current user opened the (stubbed) call screen.
  Future<Result<void>> recordJoin(String meetingId);

  /// Host only.
  Future<Result<void>> startMeeting(String meetingId);

  /// Host only.
  Future<Result<void>> endMeeting(String meetingId);

  /// Host only.
  Future<Result<void>> setLocked({required String meetingId, required bool locked});

  /// Host only.
  Future<Result<void>> removeParticipant({
    required String meetingId,
    required String userId,
  });

  Stream<List<MeetingMessage>> watchMeetingMessages(String meetingId);

  Future<Result<void>> sendMeetingMessage({
    required String meetingId,
    required String content,
  });

  Future<Result<void>> deleteMeetingMessage(String messageId);
}
