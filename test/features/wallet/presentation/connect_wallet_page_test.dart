import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/wallet/application/wallet_providers.dart';
import 'package:pulsehub/features/wallet/presentation/connect_wallet_page.dart';

import '../../../helpers/fake_wallet_repository.dart';

void main() {
  late FakeWalletRepository fakeWalletRepository;

  setUp(() {
    fakeWalletRepository = FakeWalletRepository();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [walletRepositoryProvider.overrideWithValue(fakeWalletRepository)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ConnectWalletPage()),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('rejects an empty address without calling the service', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(find.text('Wallet address is required'), findsOneWidget);
    expect(fakeWalletRepository.connectWalletCallCount, 0);
  });

  testWidgets('rejects a too-short address', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextFormField), 'short');
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(find.text("That doesn't look like a valid wallet address"), findsOneWidget);
    expect(fakeWalletRepository.connectWalletCallCount, 0);
  });

  testWidgets('connects a valid address and pops on success', (tester) async {
    await pumpPage(tester);

    await tester.enterText(
      find.byType(TextFormField),
      '0x1234567890abcdef1234567890abcdef12345678',
    );
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(fakeWalletRepository.connectWalletCallCount, 1);
    expect(find.byType(ConnectWalletPage), findsNothing);
  });

  testWidgets('shows an error message when connecting fails', (tester) async {
    fakeWalletRepository.connectWalletResult = const Result.failure(ServerException('nope'));
    await pumpPage(tester);

    await tester.enterText(
      find.byType(TextFormField),
      '0x1234567890abcdef1234567890abcdef12345678',
    );
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(find.text('nope'), findsOneWidget);
  });
}
