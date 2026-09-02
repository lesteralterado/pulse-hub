import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/services/auth/supabase_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  group('SupabaseAuthService.mapAuthError', () {
    test('maps a Supabase AuthException to our AuthException', () {
      final result = SupabaseAuthService.mapAuthError(
        const supabase.AuthException(
          'Invalid login credentials',
          statusCode: '400',
        ),
      );

      expect(result, isA<AuthException>());
      expect(result.message, 'Invalid login credentials');
    });

    test('maps an arbitrary error to UnknownException', () {
      final result = SupabaseAuthService.mapAuthError(Exception('boom'));

      expect(result, isA<UnknownException>());
    });
  });
}
