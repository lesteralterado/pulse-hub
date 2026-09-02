import 'package:flutter/material.dart';

import '../../../../core/utils/relative_time.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.content,
    required this.createdAt,
    required this.isMine,
    required this.onDelete,
    this.senderName,
  });

  final String content;
  final DateTime createdAt;
  final bool isMine;
  final VoidCallback? onDelete;

  /// Shown above the bubble in group chats for messages from other people.
  final String? senderName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bubbleColor = isMine ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHigh;
    final textColor = isMine ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (senderName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                senderName!,
                style: theme.textTheme.labelSmall?.copyWith(color: textColor),
              ),
            ),
          Text(content, style: TextStyle(color: textColor)),
          const SizedBox(height: 2),
          Text(
            formatRelativeTime(createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: isMine && onDelete != null
            ? GestureDetector(
                onLongPress: onDelete,
                child: bubble,
              )
            : bubble,
      ),
    );
  }
}
