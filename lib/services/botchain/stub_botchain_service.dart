import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import 'botchain_service.dart';

/// Always fails — see [BotChainService]'s doc comment for what's
/// missing. Kept as its own class (rather than throwing from the
/// interface itself) so the failure message lives in one obvious place.
class StubBotChainService implements BotChainService {
  @override
  Future<Result<BotBalance>> getBalance(String address) async {
    return const Result.failure(
      UnknownException(
        "Blockchain integration isn't set up yet — no BOT Chain RPC endpoint is configured.",
      ),
    );
  }

  @override
  String? explorerUrlForAddress(String address) => null;
}
