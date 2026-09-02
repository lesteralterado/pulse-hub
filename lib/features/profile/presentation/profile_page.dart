import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/startup_info.dart';
import '../../../core/utils/error_presenter.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../auth/application/auth_providers.dart';
import '../application/profile_providers.dart';
import '../domain/user_profile.dart';

/// The signed-in user's profile (section 25 groundwork: photo, name,
/// bio, joined date). Social fields (posts/communities/achievements/
/// learning progress) show empty states until their owning phases land.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(currentUserProvider)?.email ?? '';
    final profileAsync = ref.watch(myProfileProvider);
    final startupInfo = ref.watch(startupInfoProvider);
    final isSigningOut = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileHeader(email: email, profileAsync: profileAsync),
          const SizedBox(height: 20),
          const EmptyStateCard(
            title: 'Posts',
            icon: Icons.article_outlined,
            message: 'No posts yet.',
          ),
          const SizedBox(height: 12),
          const EmptyStateCard(
            title: 'Communities',
            icon: Icons.groups_outlined,
            message: 'Not in any communities yet.',
          ),
          const SizedBox(height: 12),
          const EmptyStateCard(
            title: 'Achievements',
            icon: Icons.emoji_events_outlined,
            message: 'No achievements yet.',
          ),
          const SizedBox(height: 12),
          const EmptyStateCard(
            title: 'Learning progress',
            icon: Icons.auto_stories_outlined,
            message: 'No courses started yet.',
          ),
          const SizedBox(height: 20),
          _AboutSection(
            environment: startupInfo.environment,
            supabaseConfigured: startupInfo.supabaseConfigured,
          ),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: isSigningOut
                ? null
                : () => ref.read(authControllerProvider.notifier).signOut(),
            icon: isSigningOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.email, required this.profileAsync});

  final String email;
  final AsyncValue<UserProfile> profileAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(initial, style: theme.textTheme.titleLarge),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profileAsync.when(
                    data: (profile) => Text(
                      profile.displayName ?? email,
                      style: theme.textTheme.titleMedium,
                    ),
                    loading: () => Text(email, style: theme.textTheme.titleMedium),
                    error: (_, _) => Text(email, style: theme.textTheme.titleMedium),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  profileAsync.when(
                    data: (profile) => Text(
                      'Joined ${_formatDate(profile.createdAt)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    loading: () => const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (error, _) => Text(
                      describeError(error),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({
    required this.environment,
    required this.supabaseConfigured,
  });

  final String environment;
  final bool supabaseConfigured;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedStyle = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Environment: $environment', style: mutedStyle),
            Text(
              'Supabase: ${supabaseConfigured ? 'Connected' : 'Not configured'}',
              style: mutedStyle,
            ),
          ],
        ),
      ),
    );
  }
}
