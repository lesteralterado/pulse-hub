import '../../../core/errors/result.dart';
import '../domain/wallet.dart';
import '../domain/wallet_transaction.dart';

/// Kept as an interface (implemented by [SupabaseWalletRepository]) so
/// widget/provider tests can substitute a fake instead of hitting a real
/// Supabase project — same pattern as the other repositories.
abstract class WalletRepository {
  /// null if the user hasn't connected a wallet.
  Future<Result<Wallet?>> getMyWallet();

  /// Registers [address] as the user's wallet (read-only/watch mode — no
  /// signing, no key custody). Replaces any previously connected wallet.
  Future<Result<void>> connectWallet(String address);

  Future<Result<void>> disconnectWallet();

  /// Always succeeds with an empty list until a backend job can sync
  /// this from the chain — see supabase/migrations/0007_wallets.sql.
  Future<Result<List<WalletTransaction>>> getTransactions();
}
