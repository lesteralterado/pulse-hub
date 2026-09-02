import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../services/supabase/supabase_service.dart';
import '../domain/conversation.dart';
import '../domain/conversation_member.dart';
import '../domain/message.dart';
import 'chat_repository.dart';

class SupabaseChatRepository implements ChatRepository {
  String get _requireUserId {
    final id = SupabaseService.client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('SupabaseChatRepository used while signed out');
    }
    return id;
  }

  @override
  Future<Result<List<Conversation>>> getConversations() async {
    try {
      final rows = await SupabaseService.client
          .from('conversation_summary')
          .select()
          .order('last_message_at', ascending: false, nullsFirst: false);
      return Result.success(rows.map(Conversation.fromMap).toList());
    } catch (error) {
      return Result.failure(mapChatError(error));
    }
  }

  @override
  Future<Result<Conversation>> getConversation(String conversationId) async {
    try {
      final row = await SupabaseService.client
          .from('conversation_summary')
          .select()
          .eq('id', conversationId)
          .single();
      return Result.success(Conversation.fromMap(row));
    } catch (error) {
      return Result.failure(mapChatError(error));
    }
  }

  @override
  Future<Result<String>> getOrCreateDirectConversation(String otherUserId) async {
    try {
      final currentUserId = _requireUserId;

      // RLS on `conversations` already restricts rows to ones the current
      // user belongs to, so filtering the embedded member on otherUserId
      // is enough to find a conversation both of them share.
      final existing = await SupabaseService.client
          .from('conversations')
          .select('id, conversation_members!inner(user_id)')
          .eq('is_group', false)
          .eq('conversation_members.user_id', otherUserId)
          .limit(1);
      if (existing.isNotEmpty) {
        return Result.success(existing.first['id'] as String);
      }

      final conversationRow = await SupabaseService.client
          .from('conversations')
          .insert({'is_group': false, 'created_by': currentUserId})
          .select()
          .single();
      final conversationId = conversationRow['id'] as String;

      await SupabaseService.client.from('conversation_members').insert([
        {'conversation_id': conversationId, 'user_id': currentUserId, 'role': 'owner'},
        {'conversation_id': conversationId, 'user_id': otherUserId, 'role': 'member'},
      ]);

      return Result.success(conversationId);
    } catch (error) {
      return Result.failure(mapChatError(error));
    }
  }

  @override
  Future<Result<String>> createGroupConversation({
    required String name,
    required List<String> memberIds,
  }) async {
    try {
      final currentUserId = _requireUserId;

      final conversationRow = await SupabaseService.client
          .from('conversations')
          .insert({'is_group': true, 'name': name, 'created_by': currentUserId})
          .select()
          .single();
      final conversationId = conversationRow['id'] as String;

      await SupabaseService.client.from('conversation_members').insert([
        {'conversation_id': conversationId, 'user_id': currentUserId, 'role': 'owner'},
        for (final memberId in memberIds)
          {'conversation_id': conversationId, 'user_id': memberId, 'role': 'member'},
      ]);

      return Result.success(conversationId);
    } catch (error) {
      return Result.failure(mapChatError(error));
    }
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    return SupabaseService.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((rows) => rows.map(Message.fromMap).toList());
  }

  @override
  Future<Result<void>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      await SupabaseService.client.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': _requireUserId,
        'content': content,
      });
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapChatError(error));
    }
  }

  @override
  Future<Result<void>> deleteMessage(String messageId) async {
    try {
      await SupabaseService.client.from('messages').delete().eq('id', messageId);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapChatError(error));
    }
  }

  @override
  Future<Result<void>> markAsRead(String conversationId) async {
    try {
      await SupabaseService.client
          .from('conversation_members')
          .update({'last_read_at': DateTime.now().toUtc().toIso8601String()})
          .eq('conversation_id', conversationId)
          .eq('user_id', _requireUserId);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapChatError(error));
    }
  }

  @override
  Future<Result<List<ConversationMember>>> getMembers(String conversationId) async {
    try {
      final rows = await SupabaseService.client
          .from('conversation_members')
          .select('*, profiles(username, full_name, avatar_url)')
          .eq('conversation_id', conversationId)
          .order('joined_at', ascending: true);
      return Result.success(rows.map(ConversationMember.fromMap).toList());
    } catch (error) {
      return Result.failure(mapChatError(error));
    }
  }

  @override
  Future<Result<void>> addMember({
    required String conversationId,
    required String userId,
  }) async {
    try {
      await SupabaseService.client.from('conversation_members').upsert(
        {'conversation_id': conversationId, 'user_id': userId, 'role': 'member'},
        onConflict: 'conversation_id,user_id',
        ignoreDuplicates: true,
      );
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapChatError(error));
    }
  }

  @override
  Future<Result<void>> removeMember({
    required String conversationId,
    required String userId,
  }) async {
    try {
      await SupabaseService.client
          .from('conversation_members')
          .delete()
          .eq('conversation_id', conversationId)
          .eq('user_id', userId);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapChatError(error));
    }
  }

  /// Extracted as a standalone function so error-mapping can be unit
  /// tested without needing a live Supabase connection.
  static AppException mapChatError(Object error) {
    if (error is supabase.PostgrestException) {
      return ServerException(error.message, cause: error);
    }
    return UnknownException('Unexpected chat error: $error', cause: error);
  }
}
