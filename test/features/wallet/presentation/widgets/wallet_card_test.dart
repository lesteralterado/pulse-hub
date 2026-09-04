import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/wallet/application/wallet_providers.dart';
import 'package:pulsehub/features/wallet/domain/wallet.dart';
import 'package:pulsehub/features/wallet/presentation/connect_wallet_page.dart';
import 'package:pulsehub/features/wallet/presentation/wallet_detail_page.dart';
import 'package:pulsehub/features/wallet/presentation/widgets/wallet_card.dart';

import '../../../../helpers/fake_botchain_service.dart';
import '../../../../helpers/fake_wallet_repository.dart';

void main() {
  late FakeWalletRepository fakeWalletRepository;
  late FakeBotChainService fakeBotChainService;

  setUp(() {
    fakeWalletRepository = FakeWalletRepository();
    fakeBotChainService = FakeBotChainService();
  });

  Future<void> pumpCard(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletRepositoryProvider.overrideWithValue(fakeWalletRepository),
          botChainServiceProvider.overrideWithValue(fakeBotChainService),
        ],
        child: const MaterialApp(home: Scaffold(body: WalletCard())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows a connect prompt with no wallet', (tester) async {
    await pumpCard(tester);

    expect(find.text('No wallet connected. Connect a wallet to see your BOT '
        'balance and recent transactions.'), findsOneWidget);
  });

  testWidgets('tapping Connect wallet opens the connect flow', (tester) async {
    await pumpCard(tester);

    await tester.tap(find.text('Connect wallet'));
    await tester.pumpAndSettle();

    expect(find.byType(ConnectWalletPage), findsOneWidget);
  });

  testWidgets('shows the abbreviated address when a wallet is connected',
      (tester) async {
    fakeWalletRepository.wallet = Wallet(
      id: 'w1',
      userId: 'u1',
      address: '0x1234567890abcdef1234567890abcdef12345678',
      createdAt: DateTime.utc(2026, 1, 1),
    );
    await pumpCard(tester);

    expect(find.text('Wallet connected'), findsOneWidget);
    expect(find.text('0x1234...5678'), findsOneWidget);
  });

  testWidgets('tapping the connected card opens the wallet detail page',
      (tester) async {
    fakeWalletRepository.wallet = Wallet(
      id: 'w1',
      userId: 'u1',
      address: '0x1234567890abcdef1234567890abcdef12345678',
      createdAt: DateTime.utc(2026, 1, 1),
    );
    await pumpCard(tester);

    await tester.tap(find.text('Wallet connected'));
    await tester.pumpAndSettle();

    expect(find.byType(WalletDetailPage), findsOneWidget);
  });
}
