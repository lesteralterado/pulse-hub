import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Snapshot of what happened during app startup (env loaded, Supabase
/// reachable), computed once in `main()` and injected via provider
/// override so the rest of the widget tree can just `ref.watch` it instead
/// of re-reading `EnvConfig`/`Supabase.instance` directly.
class StartupInfo {
  const StartupInfo({
    required this.environment,
    required this.supabaseConfigured,
  });

  final String environment;
  final bool supabaseConfigured;
}

/// Overridden in `main()`. Reading this before the override is applied is a
/// programmer error, not a runtime condition to handle gracefully.
final startupInfoProvider = Provider<StartupInfo>((ref) {
  throw UnimplementedError(
    'startupInfoProvider must be overridden with a real StartupInfo in main()',
  );
});
