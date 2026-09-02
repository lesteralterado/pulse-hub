import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/config/startup_info.dart';
import 'package:pulsehub/core/router/app_router.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';
import 'package:pulsehub/features/profile/application/profile_providers.dart';

import '../../helpers/fake_auth_service.dart';
import '../../helpers/fake_profile_repository.dart';

void main() {
  Future<FakeAuthService> pumpApp(
    WidgetTester tester, {
    AppUser? initialUser,
  }) async {
    final fakeAuthService = FakeAuthService(initialUser: initialUser);
    final fakeProfileRepository = FakeProfileRepository();
    addTearDown(fakeAuthService.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          startupInfoProvider.overrideWithValue(
            const StartupInfo(environment: 'test', supabaseConfigured: true),
          ),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(routerProvider);
            return MaterialApp.router(routerConfig: router);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return fakeAuthService;
  }

  testWidgets('unauthenticated users are redirected to /login', (tester) async {
    await pumpApp(tester);

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('authenticated users land on the home tab', (tester) async {
    await pumpApp(
      tester,
      initialUser: const AppUser(
        id: 'u1',
        email: 'user@example.com',
        isEmailVerified: true,
      ),
    );

    expect(find.text('Welcome back, user'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('signing in from /login redirects to the home tab',
      (tester) async {
    final fakeAuthService = await pumpApp(tester);
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(fakeAuthService.signInCallCount, 1);
    expect(find.text('Welcome back, user'), findsOneWidget);
  });

  testWidgets('the bottom nav switches tabs', (tester) async {
    await pumpApp(
      tester,
      initialUser: const AppUser(
        id: 'u1',
        email: 'user@example.com',
        isEmailVerified: true,
      ),
    );

    // Material 3's NavigationBar keeps a second, differently-styled Text
    // for each label around for its selection animation, so `find.text`
    // matches two widgets per destination — `.first` picks either (both
    // hit the same destination).
    await tester.tap(find.text('Community').first);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Community'), findsOneWidget);

    await tester.tap(find.text('Profile').first);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);
  });

  testWidgets('signing out from the profile tab redirects back to /login',
      (tester) async {
    await pumpApp(
      tester,
      initialUser: const AppUser(
        id: 'u1',
        email: 'user@example.com',
        isEmailVerified: true,
      ),
    );

    await tester.tap(find.text('Profile').first);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Sign out'),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
