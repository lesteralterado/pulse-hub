import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/livekit/livekit_service.dart';
import '../../../services/livekit/supabase_livekit_service.dart';
import '../data/meeting_repository.dart';
import '../data/supabase_meeting_repository.dart';
import '../domain/meeting.dart';
import '../domain/meeting_message.dart';
import '../domain/meeting_participant.dart';

final meetingRepositoryProvider = Provider<MeetingRepository>((ref) {
  return SupabaseMeetingRepository();
});

final liveKitServiceProvider = Provider<LiveKitService>((ref) {
  return SupabaseLiveKitService();
});

final meetingsProvider = FutureProvider.autoDispose<List<Meeting>>((ref) {
  return ref.watch(meetingRepositoryProvider).getMeetings().then(
        (result) => result.when(success: (v) => v, failure: (e) => throw e),
      );
});

final meetingParticipantsProvider =
    FutureProvider.autoDispose.family<List<MeetingParticipant>, String>((ref, meetingId) {
  return ref.watch(meetingRepositoryProvider).getParticipants(meetingId).then(
        (result) => result.when(success: (v) => v, failure: (e) => throw e),
      );
});

final meetingMessagesStreamProvider =
    StreamProvider.autoDispose.family<List<MeetingMessage>, String>((ref, meetingId) {
  return ref.watch(meetingRepositoryProvider).watchMeetingMessages(meetingId);
});
