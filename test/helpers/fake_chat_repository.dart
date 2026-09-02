import 'dart:async';

import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/chat/data/chat_repository.dart';
import 'package:pulsehub/features/chat/domain/conversation.dart';
import 'package:pulsehub/features/chat/domain/conversation_member.dart';
import 'package:pulsehub/features/chat/domain/message.dart';

/// In-memory [ChatRepository] double for widget/provider tests, so
/// nothing in the test suite ever touches a real Supabase project or its
/// realtime connection.
class FakeChatRepository implements ChatRepository {
  List<Conversation> conversations = [];
  Map<String, List<ConversationMember>> membersByConversation = {};
  final Map<String, StreamController<List<Message>>> _messageControllers = {};
  final Map<String, List<Message>> _messagesByConversation = {};

  Result<List<Conversation>>? getConversationsResult;
  Result<Conversation>? getConversationResult;
  Result<String>? getOrCreateDirectConversationResult;
  Result<String>? createGroupConversationResult;
  Result<void>? sendMessageResult;
  Result<void>? deleteMessageResult;
  Result<void>? markAsReadResult;
  Result<List<ConversationMember>>? getMembersResult;
  Result<void>? addMemberResult;
  Result<void>? removeMemberResult;

  int sendMessageCallCount = 0;
  int deleteMessageCallCount = 0;
  int markAsReadCallCount = 0;
  int addMemberCallCount = 0;
  int removeMemberCallCount = 0;

  /// Seeds the messages a conversation's stream starts with.
  void seedMessages(String conversationId, List<Message> messages) {
    _messagesByConversation[conversationId] = List.of(messages);
  }

  void dispose() {
    for (final controller in _messageControllers.values) {
      controller.close();
    }
  }

  @override
  Future<Result<List<Conversation>>> getConversations() async {
    return getConversationsResult ?? Result.success(conversations);
  }

  @override
  Future<Result<Conversation>> getConversation(String conversationId) async {
    if (getConversationResult != null) return getConversationResult!;
    final match = conversations.where((c) => c.id == conversationId);
    if (match.isEmpty) {
      throw StateError('No fake conversation with id $conversationId');
    }
    return Result.success(match.first);
  }

  @override
  Future<Result<String>> getOrCreateDirectConversation(String otherUserId) async {
    return getOrCreateDirectConversationResult ?? const Result.success('new-direct-id');
  }

  @override
  Future<Result<String>> createGroupConversation({
    required String name,
    required List<String> memberIds,
  }) async {
    return createGroupConversationResult ?? const Result.success('new-group-id');
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    final controller = _messageControllers.putIfAbsent(
      conversationId,
      () => StreamController<List<Message>>.broadcast(
        sync: true,
        onListen: () {},
      ),
    );
    // Replay the current snapshot to a new subscriber, mirroring
    // SupabaseStreamBuilder's initial postgrest fetch.
    Future.microtask(
      () => controller.add(List.of(_messagesByConversation[conversationId] ?? [])),
    );
    return controller.stream;
  }

  @override
  Future<Result<void>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    sendMessageCallCount++;
    final result = sendMessageResult ?? const Result<void>.success(null);
    if (result.isSuccess) {
      final messages = _messagesByConversation.putIfAbsent(conversationId, () => []);
      messages.add(Message(
        id: 'm${messages.length + 1}',
        conversationId: conversationId,
        senderId: 'fake-sender',
        content: content,
        createdAt: DateTime.now().toUtc(),
      ));
      _messageControllers[conversationId]?.add(List.of(messages));
    }
    return result;
  }

  @override
  Future<Result<void>> deleteMessage(String messageId) async {
    deleteMessageCallCount++;
    return deleteMessageResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> markAsRead(String conversationId) async {
    markAsReadCallCount++;
    return markAsReadResult ?? const Result.success(null);
  }

  @override
  Future<Result<List<ConversationMember>>> getMembers(String conversationId) async {
    return getMembersResult ??
        Result.success(membersByConversation[conversationId] ?? []);
  }

  @override
  Future<Result<void>> addMember({
    required String conversationId,
    required String userId,
  }) async {
    addMemberCallCount++;
    return addMemberResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> removeMember({
    required String conversationId,
    required String userId,
  }) async {
    removeMemberCallCount++;
    return removeMemberResult ?? const Result.success(null);
  }
}
