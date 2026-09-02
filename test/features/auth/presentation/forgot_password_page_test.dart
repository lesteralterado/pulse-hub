import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/presentation/forgot_password_page.dart';

import '../../../helpers/fake_auth_service.dart';

void main() {
  late FakeAuthService fakeAuthService;

  setUp(() {
    fakeAuthService = FakeAuthService();
  });

  tearDown(() => fakeAuthService.dispose());

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authServiceProvider.overrideWithValue(fakeAuthService)],
        child: const MaterialApp(home: ForgotPasswordPage()),
      ),
    );
  }

  testWidgets('rejects an empty email without calling the service',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Send reset link'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(fakeAuthService.sendPasswordResetEmailCallCount, 0);
  });

  testWidgets('shows a confirmation message after a successful request',
      (tester) async {
    await pumpPage(tester);

    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.tap(find.text('Send reset link'));
    await tester.pumpAndSettle();

    expect(fakeAuthService.sendPasswordResetEmailCallCount, 1);
    expect(
      find.text('Check your inbox for a password reset link.'),
      findsOneWidget,
    );
  });

  testWidgets('shows an error banner when the request fails', (tester) async {
    fakeAuthService.sendPasswordResetEmailResult = const Result.failure(
      NetworkException('No connection'),
    );
    await pumpPage(tester);

    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.tap(find.text('Send reset link'));
    await tester.pumpAndSettle();

    expect(find.text('No connection'), findsOneWidget);
  });
}
