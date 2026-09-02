import 'package:flutter/material.dart';

import '../../../../core/utils/relative_time.dart';
import '../../domain/conversation.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({super.key, required this.conversation, required this.onTap});

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = conversation.unreadCount > 0;
    final initial =
        conversation.displayName.isNotEmpty ? conversation.displayName[0].toUpperCase() : '?';
    final preview = conversation.lastMessageContent ?? 'No messages yet';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        child: conversation.isGroup ? const Icon(Icons.groups) : Text(initial),
      ),
      title: Text(
        conversation.displayName,
        style: hasUnread ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ),
      subtitle: Text(
        preview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
          color: hasUnread ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (conversation.lastMessageAt != null)
            Text(
              formatRelativeTime(conversation.lastMessageAt!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (hasUnread) ...[
            const SizedBox(height: 4),
            CircleAvatar(
              radius: 10,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                '${conversation.unreadCount}',
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
