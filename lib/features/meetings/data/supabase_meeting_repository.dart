import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../services/supabase/supabase_service.dart';
import '../domain/meeting.dart';
import '../domain/meeting_message.dart';
import '../domain/meeting_participant.dart';
import 'meeting_repository.dart';

class SupabaseMeetingRepository implements MeetingRepository {
  String get _requireUserId {
    final id = SupabaseService.client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('SupabaseMeetingRepository used while signed out');
    }
    return id;
  }

  @override
  Future<Result<List<Meeting>>> getMeetings() async {
    try {
      final rows = await SupabaseService.client
          .from('meeting_summary')
          .select()
          .order('scheduled_start');
      return Result.success(rows.map(Meeting.fromMap).toList());
    } catch (error) {
      return Result.failure(mapMeetingError(error));
    }
  }

  @override
  Future<Result<void>> createMeeting({
    required String title,
    String? description,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
  }) async {
    try {
      final hostId = _requireUserId;
      final meetingRow = await SupabaseService.client
          .from('meetings')
          .insert({
            'host_id': hostId,
            'title': title,
            'description': description,
            'scheduled_start': scheduledStart.toUtc().toIso8601String(),
            'scheduled_end': scheduledEnd.toUtc().toIso8601String(),
          })
          .select()
          .single();
      final meetingId = meetingRow['id'] as String;

      await SupabaseService.client.from('meeting_participants').insert({
        'meeting_id': meetingId,
        'user_id': hostId,
        'role': 'host',
        'rsvp_status': 'going',
      });

      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapMeetingError(error));
    }
  }

  @override
  Future<Result<List<MeetingParticipant>>> getParticipants(String meetingId) async {
    try {
      final rows = await SupabaseService.client
          .from('meeting_participants')
          .select('*, profiles(username, full_name, avatar_url)')
          .eq('meeting_id', meetingId)
          .order('created_at');
      return Result.success(rows.map(MeetingParticipant.fromMap).toList());
    } catch (error) {
      return Result.failure(mapMeetingError(error));
    }
  }

  @override
  Future<Result<void>> rsvp(String meetingId) async {
    try {
      await SupabaseService.client.from('meeting_participants').upsert(
        {
          'meeting_id': meetingId,
          'user_id': _requireUserId,
          'role': 'participant',
          'rsvp_status': 'going',
        },
        onConflict: 'meeting_id,user_id',
        // Keeps an existing row (e.g. the host's) untouched rather than
        // downgrading its role back to 'participant'.
        ignoreDuplicates: true,
      );
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapMeetingError(error));
    }
  }

  @override
  Future<Result<void>> cancelRsvp(String meetingId) async {
    try {
      await SupabaseService.client
          .from('meeting_participants')
          .delete()
          .eq('meeting_id', meetingId)
          .eq('user_id', _requireUserId);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapMeetingError(error));
    }
  }

  @override
  Future<Result<void>> recordJoin(String meetingId) async {
    try {
      await SupabaseService.client.from('meeting_participants').upsert(
        {
          'meeting_id': meetingId,
          'user_id': _requireUserId,
          'joined_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'meeting_id,user_id',
      );
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapMeetingError(error));
    }
  }

  @override
  Future<Result<void>> startMeeting(String meetingId) async {
    try {
      await SupabaseService.client
          .from('meetings')
          .update({'status': 'live'}).eq('id', meetingId);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapMeetingError(error));
    }
  }

  @override
  Future<Result<void>> endMeeting(String meetingId) async {
    try {
      await SupabaseService.client
          .from('meetings')
          .update({'status': 'ended'}).eq('id', meetingId);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapMeetingError(error));
    }
  }

  @override
  Future<Result<void>> setLocked({
    required String meetingId,
    required bool locked,
  }) async {
    try {
      await SupabaseService.client
          .from('meetings')
          .update({'locked': locked}).eq('id', meetingId);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapMeetingError(error));
    }
  }

  @override
  Future<Result<void>> removeParticipant({
    required String meetingId,
    required String userId,
  }) async {
    try {
      await SupabaseService.client
          .from('meeting_participants')
          .delete()
          .eq('meeting_id', meetingId)
          .eq('user_id', userId);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapMeetingError(error));
    }
  }

  @override
  Stream<List<MeetingMessage>> watchMeetingMessages(String meetingId) {
    return SupabaseService.client
        .from('meeting_messages')
        .stream(primaryKey: ['id'])
        .eq('meeting_id', meetingId)
        .order('created_at')
        .map((rows) => rows.map(MeetingMessage.fromMap).toList());
  }

  @override
  Future<Result<void>> sendMeetingMessage({
    required String meetingId,
    required String content,
  }) async {
    try {
      await SupabaseService.client.from('meeting_messages').insert({
        'meeting_id': meetingId,
        'sender_id': _requireUserId,
        'content': content,
      });
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapMeetingError(error));
    }
  }

  @override
  Future<Result<void>> deleteMeetingMessage(String messageId) async {
    try {
      await SupabaseService.client
          .from('meeting_messages')
          .delete()
          .eq('id', messageId);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapMeetingError(error));
    }
  }

  /// Extracted as a standalone function so error-mapping can be unit
  /// tested without needing a live Supabase connection.
  static AppException mapMeetingError(Object error) {
    if (error is supabase.PostgrestException) {
      return ServerException(error.message, cause: error);
    }
    return UnknownException('Unexpected meeting error: $error', cause: error);
  }
}
