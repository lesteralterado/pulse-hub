import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/features/learning/data/supabase_learning_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  group('SupabaseLearningRepository.mapLearningError', () {
    test('maps a PostgrestException to ServerException', () {
      final result = SupabaseLearningRepository.mapLearningError(
        const supabase.PostgrestException(
          message: 'permission denied for table quiz_answers',
          code: '42501',
        ),
      );

      expect(result, isA<ServerException>());
      expect(result.message, 'permission denied for table quiz_answers');
    });

    test('maps an arbitrary error to UnknownException', () {
      final result = SupabaseLearningRepository.mapLearningError(Exception('boom'));
      expect(result, isA<UnknownException>());
    });
  });
}
