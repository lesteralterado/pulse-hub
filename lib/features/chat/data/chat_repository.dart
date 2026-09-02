import '../../../core/errors/result.dart';
import '../domain/conversation.dart';
import '../domain/conversation_member.dart';
import '../domain/message.dart';

/// Kept as an interface (implemented by [SupabaseChatRepository]) so
/// widget/provider tests can substitute a fake instead of hitting a real
/// Supabase project — same pattern as the other repositories.
abstract class ChatRepository {
  Future<Result<List<Conversation>>> getConversations();

  Future<Result<Conversation>> getConversation(String conversationId);

  /// Finds an existing 1:1 conversation with [otherUserId], or creates
  /// one. Returns the conversation id.
  Future<Result<String>> getOrCreateDirectConversation(String otherUserId);

  /// Returns the new conversation id.
  Future<Result<String>> createGroupConversation({
    required String name,
    required List<String> memberIds,
  });

  /// Live-updating message list for a conversation, newest last.
  Stream<List<Message>> watchMessages(String conversationId);

  Future<Result<void>> sendMessage({
    required String conversationId,
    required String content,
  });

  Future<Result<void>> deleteMessage(String messageId);

  /// Marks all messages in the conversation as read up to now.
  Future<Result<void>> markAsRead(String conversationId);

  Future<Result<List<ConversationMember>>> getMembers(String conversationId);

  Future<Result<void>> addMember({
    required String conversationId,
    required String userId,
  });

  Future<Result<void>> removeMember({
    required String conversationId,
    required String userId,
  });
}
