import '../../core/errors/result.dart';

/// A BOT token balance, in whatever precision the chain reports.
class BotBalance {
  const BotBalance({required this.amount, required this.symbol});

  final num amount;
  final String symbol;
}

/// Reads live chain data for a wallet address: balance, transaction
/// sync, and the block explorer link. Kept as an interface so tests
/// never depend on it and so the mobile app doesn't need to change once
/// real BOT Chain infrastructure exists.
///
/// **This project has no BOT Chain RPC endpoint or token contract
/// address configured yet** (see the Phase 8 scoping discussion).
/// [StubBotChainService] fails every call with a clear "not set up yet"
/// message until:
/// 1. BOT Chain's RPC endpoint and the BOT token's contract address are
///    known.
/// 2. A real [BotChainService] implementation (or a Supabase Edge
///    Function this one calls, mirroring how LiveKit's token minting
///    works) queries them.
/// 3. A backend job syncs `transactions` from the chain — see
///    supabase/migrations/0007_wallets.sql.
abstract class BotChainService {
  Future<Result<BotBalance>> getBalance(String address);

  /// The block explorer URL for [address], or null if no explorer is
  /// configured yet.
  String? explorerUrlForAddress(String address);
}
