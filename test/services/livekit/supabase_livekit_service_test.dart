import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/services/livekit/supabase_livekit_service.dart';

void main() {
  group('SupabaseLiveKitService', () {
    test('getAccessToken fails gracefully rather than throwing', () async {
      // No real LiveKit deployment (or even a live Supabase connection)
      // exists in tests — this should come back as a Result.failure with
      // a clear message, not an unhandled exception.
      final service = SupabaseLiveKitService();

      final result = await service.getAccessToken('meeting-1');

      expect(result, isA<Failure<String>>());
      result.when(
        success: (_) => fail('expected a failure'),
        failure: (error) => expect(error.message, contains('not set up yet')),
      );
    });
  });
}
