import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/startup_info.dart';
import '../../../core/utils/error_presenter.dart';
import '../../../core/widgets/empty_state_card.dart';
import '../../auth/application/auth_providers.dart';
import '../../learning/application/learning_providers.dart';
import '../../learning/domain/achievement.dart';
import '../../learning/domain/course.dart';
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
    final achievementsAsync = ref.watch(myAchievementsProvider);
    final coursesAsync = ref.watch(coursesProvider);

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
          _AchievementsSection(achievementsAsync: achievementsAsync),
          const SizedBox(height: 12),
          _LearningProgressSection(coursesAsync: coursesAsync),
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

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection({required this.achievementsAsync});

  final AsyncValue<List<UserAchievement>> achievementsAsync;

  @override
  Widget build(BuildContext context) {
    return achievementsAsync.when(
      loading: () => const EmptyStateCard(
        title: 'Achievements',
        icon: Icons.emoji_events_outlined,
        message: 'Loading...',
      ),
      error: (error, _) => EmptyStateCard(
        title: 'Achievements',
        icon: Icons.emoji_events_outlined,
        message: describeError(error),
      ),
      data: (earned) {
        if (earned.isEmpty) {
          return const EmptyStateCard(
            title: 'Achievements',
            icon: Icons.emoji_events_outlined,
            message: 'No achievements yet. Complete a lesson to earn your first one.',
          );
        }
        final theme = Theme.of(context);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Achievements', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: earned.map((userAchievement) {
                    final achievement = Achievement.byCode(userAchievement.achievementCode);
                    if (achievement == null) return const SizedBox.shrink();
                    return Chip(
                      avatar: Icon(achievement.icon, size: 18),
                      label: Text(achievement.name),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LearningProgressSection extends StatelessWidget {
  const _LearningProgressSection({required this.coursesAsync});

  final AsyncValue<List<Course>> coursesAsync;

  @override
  Widget build(BuildContext context) {
    return coursesAsync.when(
      loading: () => const EmptyStateCard(
        title: 'Learning progress',
        icon: Icons.auto_stories_outlined,
        message: 'Loading...',
      ),
      error: (error, _) => EmptyStateCard(
        title: 'Learning progress',
        icon: Icons.auto_stories_outlined,
        message: describeError(error),
      ),
      data: (courses) {
        final started = courses.where((c) => c.isStarted).toList();
        if (started.isEmpty) {
          return const EmptyStateCard(
            title: 'Learning progress',
            icon: Icons.auto_stories_outlined,
            message: 'No courses started yet.',
          );
        }
        final theme = Theme.of(context);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Learning progress', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                for (final course in started) ...[
                  Text(course.title, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: course.completionRatio),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        );
      },
    );
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
