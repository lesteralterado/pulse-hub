/// A row from the `profiles` table (see
/// supabase/migrations/0001_profiles_and_roles.sql), auto-created for
/// every signed-up user.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.avatarUrl,
    required this.bio,
    required this.createdAt,
  });

  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final DateTime createdAt;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      username: map['username'] as String?,
      fullName: map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      bio: map['bio'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Best available label for display: full name, falling back to
  /// username, falling back to null (caller should then use the email).
  String? get displayName => fullName?.isNotEmpty == true ? fullName : username;
}
