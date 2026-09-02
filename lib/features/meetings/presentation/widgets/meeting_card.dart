import 'package:flutter/material.dart';

import '../../domain/meeting.dart';

class MeetingCard extends StatelessWidget {
  const MeetingCard({super.key, required this.meeting, required this.onTap});

  final Meeting meeting;
  final VoidCallback onTap;

  Color _statusColor(ThemeData theme) {
    switch (meeting.displayStatus) {
      case 'Live':
        return theme.colorScheme.error;
      case 'Starting soon':
        return Colors.orange;
      case 'Ended':
      case 'Cancelled':
        return theme.colorScheme.onSurfaceVariant;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(meeting.title, style: theme.textTheme.titleMedium),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(theme).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      meeting.displayStatus,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: _statusColor(theme)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Hosted by ${meeting.hostDisplayName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: 4),
                  Text(_formatDateTime(meeting.scheduledStart)),
                  const SizedBox(width: 16),
                  const Icon(Icons.people_outline, size: 16),
                  const SizedBox(width: 4),
                  Text('${meeting.participantCount}'),
                  if (meeting.isGoing) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text('Going', style: TextStyle(color: theme.colorScheme.primary)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
