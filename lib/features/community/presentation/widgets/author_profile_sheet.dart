import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_presenter.dart';
import '../../../profile/application/profile_providers.dart';

/// Lightweight read-only profile preview shown when tapping a post/comment
/// author — the community "Profiles" surface for this phase, without a
/// dedicated route or the follow/unfollow graph (deferred).
Future<void> showAuthorProfileSheet(BuildContext context, String userId) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => _AuthorProfileSheet(userId: userId),
  );
}

class _AuthorProfileSheet extends ConsumerWidget {
  const _AuthorProfileSheet({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileByIdProvider(userId));
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: profileAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(describeError(error), textAlign: TextAlign.center),
        ),
        data: (profile) {
          final name = profile.displayName ?? profile.username ?? 'PulseHub member';
          final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        Text(name, style: theme.textTheme.titleMedium),
                        if (profile.username != null)
                          Text(
                            '@${profile.username}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                profile.bio?.isNotEmpty == true ? profile.bio! : 'No bio yet.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          );
        },
      ),
    );
  }
}
