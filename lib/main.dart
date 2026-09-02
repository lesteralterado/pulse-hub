import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/env_config.dart';
import 'core/config/startup_info.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'services/supabase/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await EnvConfig.load();
  } catch (error, stackTrace) {
    AppLogger.warning('No .env file found — copy .env.example to .env');
    AppLogger.error('EnvConfig.load failed', error, stackTrace);
  }

  var supabaseConfigured = false;
  try {
    await SupabaseService.init();
    supabaseConfigured = true;
  } catch (error, stackTrace) {
    AppLogger.error('Supabase initialization failed', error, stackTrace);
  }

  runApp(
    ProviderScope(
      overrides: [
        startupInfoProvider.overrideWithValue(
          StartupInfo(
            environment: EnvConfig.environment,
            supabaseConfigured: supabaseConfigured,
          ),
        ),
      ],
      child: const PulseHubApp(),
    ),
  );
}

class PulseHubApp extends ConsumerWidget {
  const PulseHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
