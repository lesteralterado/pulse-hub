/// The app's own view of a signed-in user, decoupled from the Supabase SDK
/// type so features never import `package:supabase_flutter` directly.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
  });

  final String id;
  final String email;
  final bool isEmailVerified;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          other.id == id &&
          other.email == email &&
          other.isEmailVerified == isEmailVerified;

  @override
  int get hashCode => Object.hash(id, email, isEmailVerified);
}
