import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/features/chat/data/supabase_chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  group('SupabaseChatRepository.mapChatError', () {
    test('maps a PostgrestException to ServerException', () {
      final result = SupabaseChatRepository.mapChatError(
        const supabase.PostgrestException(
          message: 'new row violates row-level security policy',
          code: '42501',
        ),
      );

      expect(result, isA<ServerException>());
      expect(result.message, 'new row violates row-level security policy');
    });

    test('maps an arbitrary error to UnknownException', () {
      final result = SupabaseChatRepository.mapChatError(Exception('boom'));
      expect(result, isA<UnknownException>());
    });
  });
}
