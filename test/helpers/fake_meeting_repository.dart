import 'dart:async';

import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/meetings/data/meeting_repository.dart';
import 'package:pulsehub/features/meetings/domain/meeting.dart';
import 'package:pulsehub/features/meetings/domain/meeting_message.dart';
import 'package:pulsehub/features/meetings/domain/meeting_participant.dart';

/// In-memory [MeetingRepository] double for widget/provider tests, so
/// nothing in the test suite ever touches a real Supabase project or its
/// realtime connection.
class FakeMeetingRepository implements MeetingRepository {
  List<Meeting> meetings = [];
  Map<String, List<MeetingParticipant>> participantsByMeeting = {};
  final Map<String, StreamController<List<MeetingMessage>>> _messageControllers = {};
  final Map<String, List<MeetingMessage>> _messagesByMeeting = {};

  Result<void>? createMeetingResult;
  Result<void>? rsvpResult;
  Result<void>? cancelRsvpResult;
  Result<void>? recordJoinResult;
  Result<void>? startMeetingResult;
  Result<void>? endMeetingResult;
  Result<void>? setLockedResult;
  Result<void>? removeParticipantResult;
  Result<void>? sendMeetingMessageResult;
  Result<void>? deleteMeetingMessageResult;

  int createMeetingCallCount = 0;
  int rsvpCallCount = 0;
  int cancelRsvpCallCount = 0;
  int recordJoinCallCount = 0;
  int startMeetingCallCount = 0;
  int endMeetingCallCount = 0;
  int setLockedCallCount = 0;
  int removeParticipantCallCount = 0;
  int sendMeetingMessageCallCount = 0;
  int deleteMeetingMessageCallCount = 0;

  void seedMessages(String meetingId, List<MeetingMessage> messages) {
    _messagesByMeeting[meetingId] = List.of(messages);
  }

  void dispose() {
    for (final controller in _messageControllers.values) {
      controller.close();
    }
  }

  @override
  Future<Result<List<Meeting>>> getMeetings() async => Result.success(meetings);

  @override
  Future<Result<void>> createMeeting({
    required String title,
    String? description,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
  }) async {
    createMeetingCallCount++;
    return createMeetingResult ?? const Result.success(null);
  }

  @override
  Future<Result<List<MeetingParticipant>>> getParticipants(String meetingId) async {
    return Result.success(participantsByMeeting[meetingId] ?? []);
  }

  @override
  Future<Result<void>> rsvp(String meetingId) async {
    rsvpCallCount++;
    return rsvpResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> cancelRsvp(String meetingId) async {
    cancelRsvpCallCount++;
    return cancelRsvpResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> recordJoin(String meetingId) async {
    recordJoinCallCount++;
    return recordJoinResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> startMeeting(String meetingId) async {
    startMeetingCallCount++;
    return startMeetingResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> endMeeting(String meetingId) async {
    endMeetingCallCount++;
    return endMeetingResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> setLocked({
    required String meetingId,
    required bool locked,
  }) async {
    setLockedCallCount++;
    return setLockedResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> removeParticipant({
    required String meetingId,
    required String userId,
  }) async {
    removeParticipantCallCount++;
    return removeParticipantResult ?? const Result.success(null);
  }

  @override
  Stream<List<MeetingMessage>> watchMeetingMessages(String meetingId) {
    final controller = _messageControllers.putIfAbsent(
      meetingId,
      () => StreamController<List<MeetingMessage>>.broadcast(sync: true),
    );
    Future.microtask(
      () => controller.add(List.of(_messagesByMeeting[meetingId] ?? [])),
    );
    return controller.stream;
  }

  @override
  Future<Result<void>> sendMeetingMessage({
    required String meetingId,
    required String content,
  }) async {
    sendMeetingMessageCallCount++;
    final result = sendMeetingMessageResult ?? const Result<void>.success(null);
    if (result.isSuccess) {
      final messages = _messagesByMeeting.putIfAbsent(meetingId, () => []);
      messages.add(MeetingMessage(
        id: 'm${messages.length + 1}',
        meetingId: meetingId,
        senderId: 'fake-sender',
        content: content,
        createdAt: DateTime.now().toUtc(),
      ));
      _messageControllers[meetingId]?.add(List.of(messages));
    }
    return result;
  }

  @override
  Future<Result<void>> deleteMeetingMessage(String messageId) async {
    deleteMeetingMessageCallCount++;
    return deleteMeetingMessageResult ?? const Result.success(null);
  }
}
