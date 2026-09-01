import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/config/env_config.dart';

void main() {
  group('EnvConfig', () {
    test('environment defaults to development when APP_ENV is unset', () {
      dotenv.loadFromString(envString: '', isOptional: true);

      expect(EnvConfig.environment, 'development');
      expect(EnvConfig.isProduction, isFalse);
    });

    test('environment reflects APP_ENV when set', () {
      dotenv.loadFromString(envString: 'APP_ENV=production');

      expect(EnvConfig.environment, 'production');
      expect(EnvConfig.isProduction, isTrue);
    });

    test('supabaseUrl/supabaseAnonKey read from loaded values', () {
      dotenv.loadFromString(
        envString: 'SUPABASE_URL=https://test.example.com\n'
            'SUPABASE_ANON_KEY=test-anon-key\n',
      );

      expect(EnvConfig.supabaseUrl, 'https://test.example.com');
      expect(EnvConfig.supabaseAnonKey, 'test-anon-key');
    });

    test('missing required key throws a descriptive StateError', () {
      dotenv.loadFromString(envString: '', isOptional: true);

      expect(
        () => EnvConfig.supabaseUrl,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('SUPABASE_URL'),
          ),
        ),
      );
    });

    test('never-loaded dotenv is treated as no keys, not a crash', () {
      dotenv.clean();

      expect(EnvConfig.environment, 'development');
      expect(() => EnvConfig.supabaseUrl, throwsStateError);
    });
  });
}
