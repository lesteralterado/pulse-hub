import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/features/community/data/supabase_post_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  group('SupabasePostRepository.mapCommunityError', () {
    test('maps a PostgrestException to ServerException', () {
      final result = SupabasePostRepository.mapCommunityError(
        const supabase.PostgrestException(
          message: 'new row violates row-level security policy',
          code: '42501',
        ),
      );

      expect(result, isA<ServerException>());
      expect(result.message, 'new row violates row-level security policy');
    });

    test('maps an arbitrary error to UnknownException', () {
      final result = SupabasePostRepository.mapCommunityError(Exception('boom'));
      expect(result, isA<UnknownException>());
    });
  });
}
