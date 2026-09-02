/// A row from the `conversation_summary` view: a conversation the current
/// user belongs to, with its last message preview, unread count, and (for
/// 1:1 chats) the other participant's profile already joined server-side.
class Conversation {
  const Conversation({
    required this.id,
    required this.isGroup,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.lastReadAt,
    required this.lastMessageContent,
    required this.lastMessageAt,
    required this.lastMessageSenderId,
    required this.unreadCount,
    required this.otherMemberUsername,
    required this.otherMemberFullName,
    required this.otherMemberAvatarUrl,
  });

  final String id;
  final bool isGroup;
  final String? name;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? lastReadAt;
  final String? lastMessageContent;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final int unreadCount;
  final String? otherMemberUsername;
  final String? otherMemberFullName;
  final String? otherMemberAvatarUrl;

  /// Group name if this is a group chat; otherwise the other participant's
  /// display name, falling back to a generic label if neither is set.
  String get displayName {
    if (isGroup) return (name?.isNotEmpty ?? false) ? name! : 'Group chat';
    if (otherMemberFullName?.isNotEmpty ?? false) return otherMemberFullName!;
    if (otherMemberUsername?.isNotEmpty ?? false) return otherMemberUsername!;
    return 'Direct message';
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    final lastMessageAt = map['last_message_at'] as String?;
    final lastReadAt = map['last_read_at'] as String?;
    return Conversation(
      id: map['id'] as String,
      isGroup: map['is_group'] as bool,
      name: map['name'] as String?,
      createdBy: map['created_by'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastReadAt: lastReadAt == null ? null : DateTime.parse(lastReadAt),
      lastMessageContent: map['last_message_content'] as String?,
      lastMessageAt: lastMessageAt == null ? null : DateTime.parse(lastMessageAt),
      lastMessageSenderId: map['last_message_sender_id'] as String?,
      unreadCount: map['unread_count'] as int,
      otherMemberUsername: map['other_member_username'] as String?,
      otherMemberFullName: map['other_member_full_name'] as String?,
      otherMemberAvatarUrl: map['other_member_avatar_url'] as String?,
    );
  }
}
