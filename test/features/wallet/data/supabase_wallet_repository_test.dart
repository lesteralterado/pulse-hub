import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/features/wallet/data/supabase_wallet_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  group('SupabaseWalletRepository.mapWalletError', () {
    test('maps a PostgrestException to ServerException', () {
      final result = SupabaseWalletRepository.mapWalletError(
        const supabase.PostgrestException(
          message: 'duplicate key value violates unique constraint',
          code: '23505',
        ),
      );

      expect(result, isA<ServerException>());
      expect(result.message, 'duplicate key value violates unique constraint');
    });

    test('maps an arbitrary error to UnknownException', () {
      final result = SupabaseWalletRepository.mapWalletError(Exception('boom'));
      expect(result, isA<UnknownException>());
    });
  });
}
