import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_presenter.dart';
import '../../auth/application/auth_providers.dart';
import '../application/meeting_providers.dart';
import '../domain/meeting_participant.dart';
import 'widgets/meeting_message_tile.dart';

class MeetingChatPage extends ConsumerStatefulWidget {
  const MeetingChatPage({super.key, required this.meetingId});

  final String meetingId;

  @override
  ConsumerState<MeetingChatPage> createState() => _MeetingChatPageState();
}

class _MeetingChatPageState extends ConsumerState<MeetingChatPage> {
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSending = true);
    final result = await ref.read(meetingRepositoryProvider).sendMeetingMessage(
          meetingId: widget.meetingId,
          content: content,
        );
    if (!mounted) return;
    setState(() => _isSending = false);

    result.when(
      success: (_) => _messageController.clear(),
      failure: (error) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(error)))),
    );
  }

  Future<void> _delete(String messageId) async {
    final result = await ref.read(meetingRepositoryProvider).deleteMeetingMessage(messageId);
    if (!mounted) return;

    result.when(
      success: (_) {},
      failure: (error) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(error)))),
    );
  }

  MeetingParticipant? _findParticipant(List<MeetingParticipant> participants, String userId) {
    for (final participant in participants) {
      if (participant.userId == userId) return participant;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messagesAsync = ref.watch(meetingMessagesStreamProvider(widget.meetingId));
    final participantsAsync = ref.watch(meetingParticipantsProvider(widget.meetingId));
    final currentUserId = ref.watch(currentUserProvider)?.id;
    final participants = participantsAsync.value ?? const <MeetingParticipant>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Meeting chat')),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(describeError(error))),
              data: (messages) => messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final sender = _findParticipant(participants, message.senderId);
                        return MeetingMessageTile(
                          content: message.content,
                          createdAt: message.createdAt,
                          senderName: sender?.displayName ?? 'Someone',
                          isMine: message.senderId == currentUserId,
                          onDelete: message.senderId == currentUserId
                              ? () => _delete(message.id)
                              : null,
                        );
                      },
                    ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isSending,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSending ? null : _send,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
