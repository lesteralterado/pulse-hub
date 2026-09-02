import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/services/livekit/livekit_service.dart';

/// In-memory [LiveKitService] double. Defaults to failing, matching real
/// behavior until a LiveKit deployment exists (see LiveKitService's doc
/// comment) — tests that want a success path override [result].
class FakeLiveKitService implements LiveKitService {
  Result<String>? result;

  int getAccessTokenCallCount = 0;

  @override
  Future<Result<String>> getAccessToken(String meetingId) async {
    getAccessTokenCallCount++;
    return result ??
        const Result.failure(UnknownException("Video calling isn't set up yet."));
  }
}
