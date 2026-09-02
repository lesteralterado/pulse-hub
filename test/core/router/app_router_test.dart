import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/config/startup_info.dart';
import 'package:pulsehub/core/router/app_router.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';

import '../../helpers/fake_auth_service.dart';

void main() {
  Future<FakeAuthService> pumpApp(
    WidgetTester tester, {
    AppUser? initialUser,
  }) async {
    final fakeAuthService = FakeAuthService(initialUser: initialUser);
    addTearDown(fakeAuthService.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
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

  testWidgets('authenticated users land on the foundation status page',
      (tester) async {
    await pumpApp(
      tester,
      initialUser: const AppUser(
        id: 'u1',
        email: 'user@example.com',
        isEmailVerified: true,
      ),
    );

    expect(find.text('Foundation ready'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
  });

  testWidgets('signing in from /login redirects to the root route',
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
    expect(find.text('Foundation ready'), findsOneWidget);
  });

  testWidgets('signing out redirects back to /login', (tester) async {
    await pumpApp(
      tester,
      initialUser: const AppUser(
        id: 'u1',
        email: 'user@example.com',
        isEmailVerified: true,
      ),
    );
    expect(find.text('Foundation ready'), findsOneWidget);

    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
