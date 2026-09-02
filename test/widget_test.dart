import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/config/startup_info.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';
import 'package:pulsehub/main.dart';

import 'helpers/fake_auth_service.dart';

void main() {
  testWidgets('PulseHubApp boots and shows the foundation status page',
      (tester) async {
    final fakeAuthService = FakeAuthService(
      initialUser: const AppUser(
        id: 'u1',
        email: 'user@example.com',
        isEmailVerified: true,
      ),
    );
    addTearDown(fakeAuthService.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          startupInfoProvider.overrideWithValue(
            const StartupInfo(environment: 'test', supabaseConfigured: true),
          ),
          authServiceProvider.overrideWithValue(fakeAuthService),
        ],
        child: const PulseHubApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PulseHub'), findsOneWidget);
    expect(find.text('Foundation ready'), findsOneWidget);
    expect(find.text('Environment: '), findsOneWidget);
    expect(find.text('test'), findsOneWidget);
    expect(find.text('Supabase: '), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Signed in as: '), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
  });
}
