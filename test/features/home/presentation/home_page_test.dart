import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/constants/app_constants.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';
import 'package:pulsehub/features/home/presentation/home_page.dart';

import '../../../helpers/fake_auth_service.dart';

void main() {
  Future<void> pumpHomePage(WidgetTester tester) async {
    final fakeAuthService = FakeAuthService(
      initialUser: const AppUser(
        id: 'u1',
        email: 'user@example.com',
        isEmailVerified: true,
      ),
    );
    addTearDown(fakeAuthService.dispose);

    final router = GoRouter(
      initialLocation: AppConstants.routeHome,
      routes: [
        GoRoute(
          path: AppConstants.routeHome,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppConstants.routeCommunity,
          builder: (context, state) =>
              const Scaffold(body: Text('community-page')),
        ),
        GoRoute(
          path: AppConstants.routeLearn,
          builder: (context, state) => const Scaffold(body: Text('learn-page')),
        ),
        GoRoute(
          path: AppConstants.routeDashboard,
          builder: (context, state) =>
              const Scaffold(body: Text('dashboard-page')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authServiceProvider.overrideWithValue(fakeAuthService)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets("shows a welcome message with the user's email", (tester) async {
    await pumpHomePage(tester);

    expect(find.text('Welcome back, user'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
  });

  testWidgets('shows empty-state sections for features not built yet',
      (tester) async {
    await pumpHomePage(tester);

    expect(find.text('Community feed'), findsOneWidget);

    // The last card is below the fold in the test viewport — ListView
    // doesn't build off-screen children, so scroll it into view first.
    await tester.scrollUntilVisible(
      find.text('BOT Chain updates'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('BOT Chain updates'), findsOneWidget);
  });

  testWidgets('tapping the Community quick action navigates there',
      (tester) async {
    await pumpHomePage(tester);

    await tester.tap(find.widgetWithText(ActionChip, 'Community'));
    await tester.pumpAndSettle();

    expect(find.text('community-page'), findsOneWidget);
  });

  testWidgets('tapping Messages shows a coming-soon message', (tester) async {
    await pumpHomePage(tester);

    await tester.tap(find.widgetWithText(ActionChip, 'Messages'));
    await tester.pump();

    expect(
      find.text('Messages is coming in a future update.'),
      findsOneWidget,
    );
  });
}
