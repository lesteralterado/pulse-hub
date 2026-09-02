import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/features/profile/data/supabase_profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  group('SupabaseProfileRepository.mapProfileError', () {
    test('maps a PostgrestException to ServerException', () {
      final result = SupabaseProfileRepository.mapProfileError(
        const supabase.PostgrestException(
          message: 'relation "profiles" does not exist',
          code: '42P01',
        ),
      );

      expect(result, isA<ServerException>());
      expect(result.message, 'relation "profiles" does not exist');
    });

    test('maps an arbitrary error to UnknownException', () {
      final result = SupabaseProfileRepository.mapProfileError(
        Exception('boom'),
      );

      expect(result, isA<UnknownException>());
    });
  });
}
