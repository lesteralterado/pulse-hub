import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/config/startup_info.dart';
import 'package:pulsehub/core/router/app_router.dart';

void main() {
  testWidgets('AppRouter resolves the root route to the foundation page',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          startupInfoProvider.overrideWithValue(
            const StartupInfo(environment: 'test', supabaseConfigured: false),
          ),
        ],
        child: MaterialApp.router(routerConfig: AppRouter.router),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      AppRouter.router.routerDelegate.currentConfiguration.uri.toString(),
      '/',
    );
    expect(find.text('Foundation ready'), findsOneWidget);
  });
}
