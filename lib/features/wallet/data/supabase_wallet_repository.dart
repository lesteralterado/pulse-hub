import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../services/supabase/supabase_service.dart';
import '../domain/wallet.dart';
import '../domain/wallet_transaction.dart';
import 'wallet_repository.dart';

class SupabaseWalletRepository implements WalletRepository {
  String get _requireUserId {
    final id = SupabaseService.client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('SupabaseWalletRepository used while signed out');
    }
    return id;
  }

  @override
  Future<Result<Wallet?>> getMyWallet() async {
    try {
      final row = await SupabaseService.client
          .from('wallets')
          .select()
          .eq('user_id', _requireUserId)
          .maybeSingle();
      return Result.success(row == null ? null : Wallet.fromMap(row));
    } catch (error) {
      return Result.failure(mapWalletError(error));
    }
  }

  @override
  Future<Result<void>> connectWallet(String address) async {
    try {
      await SupabaseService.client.from('wallets').upsert(
        {'user_id': _requireUserId, 'address': address},
        onConflict: 'user_id',
      );
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapWalletError(error));
    }
  }

  @override
  Future<Result<void>> disconnectWallet() async {
    try {
      await SupabaseService.client
          .from('wallets')
          .delete()
          .eq('user_id', _requireUserId);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapWalletError(error));
    }
  }

  @override
  Future<Result<List<WalletTransaction>>> getTransactions() async {
    try {
      // RLS already restricts this to the caller's own wallet's rows —
      // see the migration's "Users can view their own wallet's
      // transactions" policy.
      final rows = await SupabaseService.client
          .from('transactions')
          .select()
          .order('created_at', ascending: false);
      return Result.success(rows.map(WalletTransaction.fromMap).toList());
    } catch (error) {
      return Result.failure(mapWalletError(error));
    }
  }

  /// Extracted as a standalone function so error-mapping can be unit
  /// tested without needing a live Supabase connection.
  static AppException mapWalletError(Object error) {
    if (error is supabase.PostgrestException) {
      return ServerException(error.message, cause: error);
    }
    return UnknownException('Unexpected wallet error: $error', cause: error);
  }
}
