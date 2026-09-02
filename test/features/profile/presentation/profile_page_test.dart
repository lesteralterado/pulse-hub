import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/config/startup_info.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';
import 'package:pulsehub/features/profile/application/profile_providers.dart';
import 'package:pulsehub/features/profile/presentation/profile_page.dart';

import '../../../helpers/fake_auth_service.dart';
import '../../../helpers/fake_profile_repository.dart';

void main() {
  late FakeAuthService fakeAuthService;
  late FakeProfileRepository fakeProfileRepository;

  setUp(() {
    fakeAuthService = FakeAuthService(
      initialUser: const AppUser(
        id: 'u1',
        email: 'user@example.com',
        isEmailVerified: true,
      ),
    );
    fakeProfileRepository = FakeProfileRepository();
  });

  tearDown(() => fakeAuthService.dispose());

  Future<void> pumpProfilePage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          startupInfoProvider.overrideWithValue(
            const StartupInfo(environment: 'test', supabaseConfigured: true),
          ),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
  }

  testWidgets('shows the signed-in email immediately, then the profile once loaded',
      (tester) async {
    await pumpProfilePage(tester);
    expect(find.text('user@example.com'), findsWidgets);

    await tester.pumpAndSettle();

    expect(find.textContaining('Joined 2026-01-01'), findsOneWidget);
    expect(fakeProfileRepository.getProfileCallCount, 1);
  });

  testWidgets('shows an error message when the profile fails to load',
      (tester) async {
    fakeProfileRepository.result = const Result.failure(
      ServerException('boom'),
    );
    await pumpProfilePage(tester);
    await tester.pumpAndSettle();

    expect(find.text('boom'), findsOneWidget);
  });

  testWidgets('shows the environment and Supabase connection status',
      (tester) async {
    await pumpProfilePage(tester);
    await tester.pumpAndSettle();

    // The About section is below the fold in the test viewport — ListView
    // doesn't build off-screen children, so scroll it into view first.
    await tester.scrollUntilVisible(
      find.text('Environment: test'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Environment: test'), findsOneWidget);
    expect(find.text('Supabase: Connected'), findsOneWidget);
  });

  testWidgets('tapping Sign out calls AuthService.signOut', (tester) async {
    await pumpProfilePage(tester);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Sign out'),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(fakeAuthService.signOutCallCount, 1);
  });
}
