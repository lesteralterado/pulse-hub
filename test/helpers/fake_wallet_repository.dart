import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/wallet/data/wallet_repository.dart';
import 'package:pulsehub/features/wallet/domain/wallet.dart';
import 'package:pulsehub/features/wallet/domain/wallet_transaction.dart';

/// In-memory [WalletRepository] double for widget/provider tests, so
/// nothing in the test suite ever touches a real Supabase project.
class FakeWalletRepository implements WalletRepository {
  Wallet? wallet;
  List<WalletTransaction> transactions = [];

  Result<void>? connectWalletResult;
  Result<void>? disconnectWalletResult;

  int connectWalletCallCount = 0;
  int disconnectWalletCallCount = 0;

  @override
  Future<Result<Wallet?>> getMyWallet() async => Result.success(wallet);

  @override
  Future<Result<void>> connectWallet(String address) async {
    connectWalletCallCount++;
    final result = connectWalletResult ?? const Result<void>.success(null);
    if (result.isSuccess) {
      wallet = Wallet(
        id: 'fake-wallet-id',
        userId: 'fake-user-id',
        address: address,
        createdAt: DateTime.now().toUtc(),
      );
    }
    return result;
  }

  @override
  Future<Result<void>> disconnectWallet() async {
    disconnectWalletCallCount++;
    final result = disconnectWalletResult ?? const Result<void>.success(null);
    if (result.isSuccess) wallet = null;
    return result;
  }

  @override
  Future<Result<List<WalletTransaction>>> getTransactions() async {
    return Result.success(transactions);
  }
}
