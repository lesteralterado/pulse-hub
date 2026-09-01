import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed access to the values loaded from `.env` (see `.env.example` for the
/// documented list of required keys). Never read `dotenv` directly outside
/// this class, so every required key is validated in exactly one place.
class EnvConfig {
  EnvConfig._();

  static bool _loaded = false;

  /// Loads `.env` from the project root. Safe to call once at startup;
  /// missing keys only surface when a specific getter below is read, so a
  /// missing file doesn't crash unrelated parts of the app.
  static Future<void> load() async {
    if (_loaded) return;
    await dotenv.load(fileName: '.env');
    _loaded = true;
  }

  static String get supabaseUrl => _require('SUPABASE_URL');

  static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');

  static String get environment => _maybeGet('APP_ENV') ?? 'development';

  static bool get isProduction => environment == 'production';

  /// [DotEnv.env] throws if `load`/`loadFromString` was never called, so
  /// treat "never loaded" the same as "key not present" instead of
  /// crashing every getter when `.env` failed to load.
  static String? _maybeGet(String key) {
    if (!dotenv.isInitialized) return null;
    return dotenv.maybeGet(key);
  }

  static String _require(String key) {
    final value = _maybeGet(key);
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing required environment variable "$key". '
        'Copy .env.example to .env and fill it in.',
      );
    }
    return value;
  }
}
