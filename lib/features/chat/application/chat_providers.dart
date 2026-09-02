import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/chat_repository.dart';
import '../data/supabase_chat_repository.dart';
import '../domain/conversation.dart';
import '../domain/conversation_member.dart';
import '../domain/message.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return SupabaseChatRepository();
});

final conversationsProvider = FutureProvider.autoDispose<List<Conversation>>((ref) {
  return ref.watch(chatRepositoryProvider).getConversations().then(
        (result) =>
            result.when(success: (value) => value, failure: (e) => throw e),
      );
});

final messagesStreamProvider =
    StreamProvider.autoDispose.family<List<Message>, String>((ref, conversationId) {
  return ref.watch(chatRepositoryProvider).watchMessages(conversationId);
});

final conversationMembersProvider = FutureProvider.autoDispose
    .family<List<ConversationMember>, String>((ref, conversationId) {
  return ref.watch(chatRepositoryProvider).getMembers(conversationId).then(
        (result) =>
            result.when(success: (value) => value, failure: (e) => throw e),
      );
});
