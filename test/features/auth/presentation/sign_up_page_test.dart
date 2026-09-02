import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pulsehub/core/constants/app_constants.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/presentation/sign_up_page.dart';
import 'package:pulsehub/features/auth/presentation/verify_email_page.dart';

import '../../../helpers/fake_auth_service.dart';

void main() {
  late FakeAuthService fakeAuthService;

  setUp(() {
    fakeAuthService = FakeAuthService();
  });

  tearDown(() => fakeAuthService.dispose());

  Future<void> pumpSignUpPage(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: AppConstants.routeSignUp,
      routes: [
        GoRoute(
          path: AppConstants.routeSignUp,
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: AppConstants.routeLogin,
          builder: (context, state) => const Scaffold(body: Text('login-page')),
        ),
        GoRoute(
          path: AppConstants.routeVerifyEmail,
          builder: (context, state) => VerifyEmailPage(
            email: state.uri.queryParameters['email'] ?? '',
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authServiceProvider.overrideWithValue(fakeAuthService)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  testWidgets('rejects mismatched passwords without calling the service',
      (tester) async {
    await pumpSignUpPage(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).at(2), 'different123');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
    expect(fakeAuthService.signUpCallCount, 0);
  });

  testWidgets(
      'calls AuthService.signUp and navigates to verify-email on success',
      (tester) async {
    await pumpSignUpPage(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(fakeAuthService.signUpCallCount, 1);
    expect(
      find.text("We've sent a verification link to user@example.com."),
      findsOneWidget,
    );
  });

  testWidgets('shows an error banner when sign-up fails', (tester) async {
    fakeAuthService.signUpResult = const Result.failure(
      AuthException('Email already registered'),
    );
    await pumpSignUpPage(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Email already registered'), findsOneWidget);
  });
}
