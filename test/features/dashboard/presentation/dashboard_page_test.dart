import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/dashboard/presentation/dashboard_page.dart';
import 'package:pulsehub/features/wallet/application/wallet_providers.dart';

import '../../../helpers/fake_wallet_repository.dart';

void main() {
  testWidgets('shows the three visually separated sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletRepositoryProvider.overrideWithValue(FakeWalletRepository()),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Dashboard'), findsOneWidget);
    expect(find.text('BOT Chain'), findsOneWidget);
    expect(find.text('CaryPact'), findsOneWidget);
    expect(find.text('PulseHub'), findsOneWidget);
  });

  testWidgets('shows a connect-wallet prompt with no wallet connected',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletRepositoryProvider.overrideWithValue(FakeWalletRepository()),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Connect wallet'), findsOneWidget);
  });
}
