import '../../core/errors/result.dart';

/// Mints a short-lived LiveKit access token for joining a meeting's video
/// room. Kept as an interface so tests never depend on it, and so the
/// mobile app doesn't need to change once a real LiveKit deployment
/// exists — only [SupabaseLiveKitService]'s Edge Function call needs a
/// real backend behind it.
///
/// **This project has no LiveKit deployment yet** (see the Phase 7
/// scoping discussion). [SupabaseLiveKitService.getAccessToken] will
/// fail every time until:
/// 1. A LiveKit Cloud project (or self-hosted server) exists.
/// 2. supabase/functions/mint-livekit-token (reference implementation,
///    not deployed) is deployed with that project's API key/secret as
///    function secrets.
/// 3. The `livekit_client` package is added and the call screen is
///    wired up to actually connect using the returned token.
abstract class LiveKitService {
  Future<Result<String>> getAccessToken(String meetingId);
}
