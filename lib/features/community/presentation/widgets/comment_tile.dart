import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/relative_time.dart';
import '../../../auth/application/auth_providers.dart';
import '../../domain/comment.dart';
import 'author_profile_sheet.dart';

class CommentTile extends ConsumerWidget {
  const CommentTile({super.key, required this.comment, required this.onDelete});

  final Comment comment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOwner = ref.watch(currentUserProvider)?.id == comment.authorId;
    final initial = comment.authorDisplayName.isNotEmpty
        ? comment.authorDisplayName[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => showAuthorProfileSheet(context, comment.authorId),
            child: CircleAvatar(radius: 16, child: Text(initial, style: theme.textTheme.bodySmall)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => showAuthorProfileSheet(context, comment.authorId),
                      child: Text(
                        comment.authorDisplayName,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatRelativeTime(comment.createdAt),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(comment.content, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
              tooltip: 'Delete comment',
            ),
        ],
      ),
    );
  }
}
