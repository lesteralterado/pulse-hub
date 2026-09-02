import 'package:flutter/material.dart';

import '../../../../core/utils/relative_time.dart';

class MeetingMessageTile extends StatelessWidget {
  const MeetingMessageTile({
    super.key,
    required this.content,
    required this.createdAt,
    required this.senderName,
    required this.isMine,
    required this.onDelete,
  });

  final String content;
  final DateTime createdAt;
  final String senderName;
  final bool isMine;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(senderName, style: theme.textTheme.labelLarge),
                    const SizedBox(width: 8),
                    Text(
                      formatRelativeTime(createdAt),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(content, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          if (isMine && onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
              tooltip: 'Delete message',
            ),
        ],
      ),
    );
  }
}
