import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/config/startup_info.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';
import 'package:pulsehub/features/profile/application/profile_providers.dart';
import 'package:pulsehub/main.dart';

import 'helpers/fake_auth_service.dart';
import 'helpers/fake_profile_repository.dart';

void main() {
  testWidgets('PulseHubApp boots and shows the home tab', (tester) async {
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
          profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
        ],
        child: const PulseHubApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PulseHub'), findsOneWidget);
    expect(find.text('Welcome back, user'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
  });
}
