/// A participant in a conversation, with their profile info embedded via
/// PostgREST (`select=*,profiles(username,full_name,avatar_url)`).
class ConversationMember {
  const ConversationMember({
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.username,
    required this.fullName,
    required this.avatarUrl,
  });

  final String userId;
  final String role;
  final DateTime joinedAt;
  final String? username;
  final String? fullName;
  final String? avatarUrl;

  String get displayName =>
      (fullName?.isNotEmpty ?? false) ? fullName! : (username ?? 'Someone');

  bool get isOwner => role == 'owner';

  factory ConversationMember.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'] as Map<String, dynamic>?;
    return ConversationMember(
      userId: map['user_id'] as String,
      role: map['role'] as String,
      joinedAt: DateTime.parse(map['joined_at'] as String),
      username: profile?['username'] as String?,
      fullName: profile?['full_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
    );
  }
}
