import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/wallet/application/wallet_providers.dart';
import 'package:pulsehub/features/wallet/domain/wallet.dart';
import 'package:pulsehub/features/wallet/domain/wallet_transaction.dart';
import 'package:pulsehub/features/wallet/presentation/wallet_detail_page.dart';
import 'package:pulsehub/services/botchain/botchain_service.dart';

import '../../../helpers/fake_botchain_service.dart';
import '../../../helpers/fake_wallet_repository.dart';

final _wallet = Wallet(
  id: 'w1',
  userId: 'u1',
  address: '0x1234567890abcdef1234567890abcdef12345678',
  createdAt: DateTime.utc(2026, 1, 1),
);

void main() {
  late FakeWalletRepository fakeWalletRepository;
  late FakeBotChainService fakeBotChainService;

  setUp(() {
    fakeWalletRepository = FakeWalletRepository()..wallet = _wallet;
    fakeBotChainService = FakeBotChainService();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletRepositoryProvider.overrideWithValue(fakeWalletRepository),
          botChainServiceProvider.overrideWithValue(fakeBotChainService),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => WalletDetailPage(wallet: _wallet)),
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

  testWidgets('shows the full address', (tester) async {
    await pumpPage(tester);
    expect(find.text(_wallet.address), findsOneWidget);
  });

  testWidgets('shows the balance failure message since chain access is stubbed',
      (tester) async {
    await pumpPage(tester);
    expect(find.text("Blockchain integration isn't set up yet."), findsOneWidget);
  });

  testWidgets('shows a real balance when the service succeeds', (tester) async {
    fakeBotChainService.balanceResult =
        const Result.success(BotBalance(amount: 42, symbol: 'BOT'));
    await pumpPage(tester);

    expect(find.text('42 BOT'), findsOneWidget);
  });

  testWidgets('shows an empty state with no transactions', (tester) async {
    await pumpPage(tester);
    expect(find.text('No transactions yet.'), findsOneWidget);
  });

  testWidgets('lists transactions when present', (tester) async {
    fakeWalletRepository.transactions = [
      WalletTransaction(
        id: 't1',
        txHash: '0xabc',
        direction: 'receive',
        amount: 5,
        counterpartyAddress: null,
        status: 'confirmed',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    ];
    await pumpPage(tester);

    expect(find.text('Received 5'), findsOneWidget);
  });

  testWidgets('tapping the explorer button shows a not-configured message',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('View on Blockchain Explorer'));
    await tester.pumpAndSettle();

    expect(
      find.text("Blockchain explorer isn't configured yet — no BOT Chain network is set up."),
      findsOneWidget,
    );
  });

  testWidgets('disconnecting confirms, then calls disconnectWallet and pops',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Disconnect wallet'));
    await tester.pumpAndSettle();

    expect(find.text('Disconnect wallet?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Disconnect'));
    await tester.pumpAndSettle();

    expect(fakeWalletRepository.disconnectWalletCallCount, 1);
    expect(find.byType(WalletDetailPage), findsNothing);
  });
}
