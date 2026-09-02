import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../auth/application/auth_providers.dart';
import '../../chat/presentation/conversations_page.dart';
import '../../meetings/application/meeting_providers.dart';
import '../../meetings/domain/meeting.dart';
import '../../meetings/presentation/meeting_detail_page.dart';
import '../../meetings/presentation/meetings_page.dart';

/// The user's personalized PulseHub feed (section 7 of the brief). The
/// data-backed sections below (feed, announcements, meetings, learning,
/// notifications, CaryPact/BOT Chain updates) show empty states until
/// their owning phases (4, 6, 7, 9, 8) wire up real data.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final displayName = currentUser?.email.split('@').first ?? 'there';
    final meetingsAsync = ref.watch(meetingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Welcome back, $displayName',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            currentUser?.email ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),
          _QuickActions(),
          const SizedBox(height: 20),
          const EmptyStateCard(
            title: 'Community feed',
            icon: Icons.dynamic_feed_outlined,
            message: 'No posts yet. Follow a community to see updates here.',
          ),
          const SizedBox(height: 12),
          const EmptyStateCard(
            title: 'Latest announcements',
            icon: Icons.campaign_outlined,
            message: 'No announcements right now.',
          ),
          const SizedBox(height: 12),
          _UpcomingMeetingsSection(meetingsAsync: meetingsAsync),
          const SizedBox(height: 12),
          const EmptyStateCard(
            title: 'Learning recommendations',
            icon: Icons.auto_stories_outlined,
            message: 'Complete your profile to get course recommendations.',
          ),
          const SizedBox(height: 12),
          const EmptyStateCard(
            title: 'Subscription status',
            icon: Icons.card_membership_outlined,
            message: 'No active subscription.',
          ),
          const SizedBox(height: 12),
          const EmptyStateCard(
            title: 'Notifications',
            icon: Icons.notifications_none,
            message: "You're all caught up.",
          ),
          const SizedBox(height: 12),
          const EmptyStateCard(
            title: 'CaryPact updates',
            icon: Icons.trending_up_outlined,
            message: 'No CaryPact activity yet.',
          ),
          const SizedBox(height: 12),
          const EmptyStateCard(
            title: 'BOT Chain updates',
            icon: Icons.link_outlined,
            message: 'Connect a wallet to see on-chain activity.',
          ),
        ],
      ),
    );
  }
}

class _UpcomingMeetingsSection extends StatelessWidget {
  const _UpcomingMeetingsSection({required this.meetingsAsync});

  final AsyncValue<List<Meeting>> meetingsAsync;

  @override
  Widget build(BuildContext context) {
    return meetingsAsync.when(
      loading: () => const EmptyStateCard(
        title: 'Upcoming meetings',
        icon: Icons.event_outlined,
        message: 'Loading...',
      ),
      error: (error, _) => const EmptyStateCard(
        title: 'Upcoming meetings',
        icon: Icons.event_outlined,
        message: 'No meetings scheduled.',
      ),
      data: (meetings) {
        final upcoming = meetings
            .where((m) => m.isGoing && (m.status == 'scheduled' || m.isLive))
            .take(3)
            .toList();
        if (upcoming.isEmpty) {
          return const EmptyStateCard(
            title: 'Upcoming meetings',
            icon: Icons.event_outlined,
            message: 'No meetings scheduled.',
          );
        }
        final theme = Theme.of(context);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upcoming meetings', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final meeting in upcoming)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      meeting.isLive ? Icons.videocam : Icons.event_outlined,
                      color: meeting.isLive ? theme.colorScheme.error : null,
                    ),
                    title: Text(meeting.title),
                    subtitle: Text(meeting.displayStatus),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MeetingDetailPage(meeting: meeting),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _QuickActionChip(
          icon: Icons.groups_outlined,
          label: 'Community',
          onTap: () => context.go(AppConstants.routeCommunity),
        ),
        _QuickActionChip(
          icon: Icons.chat_bubble_outline,
          label: 'Messages',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ConversationsPage()),
          ),
        ),
        _QuickActionChip(
          icon: Icons.school_outlined,
          label: 'Learn',
          onTap: () => context.go(AppConstants.routeLearn),
        ),
        _QuickActionChip(
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
          onTap: () => context.go(AppConstants.routeDashboard),
        ),
        _QuickActionChip(
          icon: Icons.event_outlined,
          label: 'Meetings',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MeetingsPage()),
          ),
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
