import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env_config.dart';
import '../../core/utils/app_logger.dart';

/// Thin wrapper around the Supabase SDK's own singleton so the rest of the
/// app depends on `SupabaseService`, not on `Supabase.instance` directly —
/// keeps the backend swappable per the brief's service-layer architecture.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      publishableKey: EnvConfig.supabaseAnonKey,
    );
    AppLogger.info('Supabase initialized (${EnvConfig.environment})');
  }
}
