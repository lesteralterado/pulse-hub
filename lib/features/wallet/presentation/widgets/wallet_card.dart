import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_presenter.dart';
import '../../application/wallet_providers.dart';
import '../connect_wallet_page.dart';
import '../wallet_detail_page.dart';

/// The BOT Chain section of the Dashboard tab: a connect prompt, or a
/// summary of the connected wallet linking to [WalletDetailPage].
class WalletCard extends ConsumerWidget {
  const WalletCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(myWalletProvider);
    final theme = Theme.of(context);

    return walletAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(describeError(error)),
        ),
      ),
      data: (wallet) {
        if (wallet == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined),
                      const SizedBox(width: 8),
                      Text('Wallet & balance', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No wallet connected. Connect a wallet to see your BOT '
                    'balance and recent transactions.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ConnectWalletPage()),
                    ),
                    child: const Text('Connect wallet'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => WalletDetailPage(wallet: wallet)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Wallet connected', style: theme.textTheme.titleMedium),
                        Text(
                          wallet.displayAddress,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
