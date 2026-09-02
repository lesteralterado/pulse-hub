/// A participant row, with their profile info embedded via PostgREST
/// (`select=*,profiles(username,full_name,avatar_url)`).
class MeetingParticipant {
  const MeetingParticipant({
    required this.userId,
    required this.role,
    required this.rsvpStatus,
    required this.joinedAt,
    required this.username,
    required this.fullName,
    required this.avatarUrl,
  });

  final String userId;
  final String role;
  final String rsvpStatus;
  final DateTime? joinedAt;
  final String? username;
  final String? fullName;
  final String? avatarUrl;

  String get displayName =>
      (fullName?.isNotEmpty ?? false) ? fullName! : (username ?? 'Someone');

  bool get isHost => role == 'host';
  bool get isCoHost => role == 'co_host';

  factory MeetingParticipant.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'] as Map<String, dynamic>?;
    final joinedAt = map['joined_at'] as String?;
    return MeetingParticipant(
      userId: map['user_id'] as String,
      role: map['role'] as String,
      rsvpStatus: map['rsvp_status'] as String,
      joinedAt: joinedAt == null ? null : DateTime.parse(joinedAt),
      username: profile?['username'] as String?,
      fullName: profile?['full_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
    );
  }
}
