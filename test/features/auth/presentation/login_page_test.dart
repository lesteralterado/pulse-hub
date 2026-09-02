import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/presentation/login_page.dart';

import '../../../helpers/fake_auth_service.dart';

void main() {
  late FakeAuthService fakeAuthService;

  setUp(() {
    fakeAuthService = FakeAuthService();
  });

  tearDown(() => fakeAuthService.dispose());

  Future<void> pumpLoginPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authServiceProvider.overrideWithValue(fakeAuthService)],
        child: const MaterialApp(home: LoginPage()),
      ),
    );
  }

  testWidgets('shows validation errors on empty submit', (tester) async {
    await pumpLoginPage(tester);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(fakeAuthService.signInCallCount, 0);
  });

  testWidgets('calls AuthService.signIn with the entered credentials',
      (tester) async {
    await pumpLoginPage(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(fakeAuthService.signInCallCount, 1);
  });

  testWidgets('shows an error banner when sign-in fails', (tester) async {
    fakeAuthService.signInResult = const Result.failure(
      AuthException('Invalid login credentials'),
    );
    await pumpLoginPage(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid login credentials'), findsOneWidget);
  });
}
