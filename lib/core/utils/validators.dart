/// Pure form-field validators, kept free of any widget/Supabase dependency
/// so they can be unit tested directly and reused across every auth form.
abstract final class Validators {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(trimmed)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final input = value ?? '';
    if (input.isEmpty) return 'Password is required';
    if (input.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value != password) return 'Passwords do not match';
    return null;
  }
}
