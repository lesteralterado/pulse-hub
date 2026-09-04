import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/services/botchain/botchain_service.dart';

/// In-memory [BotChainService] double. Defaults to failing, matching
/// real behavior until BOT Chain infrastructure exists (see
/// BotChainService's doc comment) — tests that want a success path
/// override [balanceResult].
class FakeBotChainService implements BotChainService {
  Result<BotBalance>? balanceResult;
  String? explorerUrl;

  @override
  Future<Result<BotBalance>> getBalance(String address) async {
    return balanceResult ??
        const Result.failure(UnknownException("Blockchain integration isn't set up yet."));
  }

  @override
  String? explorerUrlForAddress(String address) => explorerUrl;
}
