import '../../core/errors/app_exception.dart';
import '../../core/errors/result.dart';
import '../supabase/supabase_service.dart';
import 'livekit_service.dart';

class SupabaseLiveKitService implements LiveKitService {
  @override
  Future<Result<String>> getAccessToken(String meetingId) async {
    try {
      final response = await SupabaseService.client.functions.invoke(
        'mint-livekit-token',
        body: {'meeting_id': meetingId},
      );
      final data = response.data;
      final token = data is Map ? data['token'] as String? : null;
      if (token == null) {
        return const Result.failure(
          UnknownException('mint-livekit-token did not return a token'),
        );
      }
      return Result.success(token);
    } catch (error) {
      // Expected to fail until a LiveKit deployment + the
      // mint-livekit-token function (see supabase/functions/) exist —
      // see LiveKitService's doc comment.
      return Result.failure(
        UnknownException('Video calling is not set up yet.', cause: error),
      );
    }
  }
}
