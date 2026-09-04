import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/botchain/botchain_service.dart';
import '../../../services/botchain/stub_botchain_service.dart';
import '../data/supabase_wallet_repository.dart';
import '../data/wallet_repository.dart';
import '../domain/wallet.dart';
import '../domain/wallet_transaction.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return SupabaseWalletRepository();
});

final botChainServiceProvider = Provider<BotChainService>((ref) {
  return StubBotChainService();
});

final myWalletProvider = FutureProvider.autoDispose<Wallet?>((ref) {
  return ref.watch(walletRepositoryProvider).getMyWallet().then(
        (result) => result.when(success: (v) => v, failure: (e) => throw e),
      );
});

final walletBalanceProvider =
    FutureProvider.autoDispose.family<BotBalance, String>((ref, address) {
  return ref.watch(botChainServiceProvider).getBalance(address).then(
        (result) => result.when(success: (v) => v, failure: (e) => throw e),
      );
});

final walletTransactionsProvider = FutureProvider.autoDispose<List<WalletTransaction>>((ref) {
  return ref.watch(walletRepositoryProvider).getTransactions().then(
        (result) => result.when(success: (v) => v, failure: (e) => throw e),
      );
});
