import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state_card.dart';

/// The investor dashboard (section 15): BOT Chain, CaryPact and PulseHub
/// data, kept visually separated so it's clear which system each figure
/// comes from. Real data is wired up in Phase 8 (BOT Chain), Phase 9
/// (CaryPact) and Phase 10 (Subscriptions) — this is the Core UI skeleton.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('BOT Chain'),
          const EmptyStateCard(
            title: 'Wallet & balance',
            icon: Icons.account_balance_wallet_outlined,
            message:
                'No wallet connected. Connect a wallet to see your BOT '
                'balance, assets and recent transactions.',
          ),
          const SizedBox(height: 24),
          _SectionHeader('CaryPact'),
          const EmptyStateCard(
            title: 'Investments & rewards',
            icon: Icons.trending_up_outlined,
            message:
                'No CaryPact investment data yet. Investment amount, '
                'assets, rewards and ROI will appear here.',
          ),
          const SizedBox(height: 24),
          _SectionHeader('PulseHub'),
          const EmptyStateCard(
            title: 'Subscription & activity',
            icon: Icons.insights_outlined,
            message:
                'No subscription or activity data yet. Your plan, '
                'learning progress and community activity will appear here.',
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
