import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/error_presenter.dart';
import '../../../core/utils/relative_time.dart';
import '../application/wallet_providers.dart';
import '../domain/wallet.dart';

class WalletDetailPage extends ConsumerStatefulWidget {
  const WalletDetailPage({super.key, required this.wallet});

  final Wallet wallet;

  @override
  ConsumerState<WalletDetailPage> createState() => _WalletDetailPageState();
}

class _WalletDetailPageState extends ConsumerState<WalletDetailPage> {
  bool _isDisconnecting = false;

  Future<void> _disconnect() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect wallet?'),
        content: const Text(
          "This only removes the address from PulseHub's view — it has no "
          'effect on the wallet itself.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDisconnecting = true);
    final result = await ref.read(walletRepositoryProvider).disconnectWallet();
    if (!mounted) return;

    result.when(
      success: (_) {
        ref.invalidate(myWalletProvider);
        Navigator.of(context).pop();
      },
      failure: (error) {
        setState(() => _isDisconnecting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error))));
      },
    );
  }

  Future<void> _openExplorer() async {
    final url = ref.read(botChainServiceProvider).explorerUrlForAddress(widget.wallet.address);
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Blockchain explorer isn't configured yet — no BOT Chain network is set up.",
          ),
        ),
      );
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balanceAsync = ref.watch(walletBalanceProvider(widget.wallet.address));
    final transactionsAsync = ref.watch(walletTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Address', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  SelectableText(
                    widget.wallet.address,
                    style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 12),
                  Text('BOT balance', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  balanceAsync.when(
                    loading: () => const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (error, _) => Text(
                      describeError(error),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    data: (balance) => Text(
                      '${balance.amount} ${balance.symbol}',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _openExplorer,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('View on Blockchain Explorer'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Transaction history', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          transactionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(describeError(error)),
            data: (transactions) => transactions.isEmpty
                ? Text(
                    'No transactions yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : Column(
                    children: transactions.map((tx) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          tx.isSend ? Icons.arrow_upward : Icons.arrow_downward,
                          color: tx.isSend ? theme.colorScheme.error : theme.colorScheme.primary,
                        ),
                        title: Text('${tx.isSend ? 'Sent' : 'Received'} ${tx.amount}'),
                        subtitle: Text(formatRelativeTime(tx.createdAt)),
                        trailing: Text(tx.status),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: _isDisconnecting ? null : _disconnect,
            child: _isDisconnecting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Disconnect wallet'),
          ),
        ],
      ),
    );
  }
}
