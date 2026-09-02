import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/features/meetings/data/supabase_meeting_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  group('SupabaseMeetingRepository.mapMeetingError', () {
    test('maps a PostgrestException to ServerException', () {
      final result = SupabaseMeetingRepository.mapMeetingError(
        const supabase.PostgrestException(
          message: 'permission denied for table meetings',
          code: '42501',
        ),
      );

      expect(result, isA<ServerException>());
      expect(result.message, 'permission denied for table meetings');
    });

    test('maps an arbitrary error to UnknownException', () {
      final result = SupabaseMeetingRepository.mapMeetingError(Exception('boom'));
      expect(result, isA<UnknownException>());
    });
  });
}
