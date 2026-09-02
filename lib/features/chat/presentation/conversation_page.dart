import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_presenter.dart';
import '../../auth/application/auth_providers.dart';
import '../application/chat_providers.dart';
import '../domain/conversation.dart';
import '../domain/conversation_member.dart';
import 'widgets/group_members_sheet.dart';
import 'widgets/message_bubble.dart';

class ConversationPage extends ConsumerStatefulWidget {
  const ConversationPage({super.key, required this.conversation});

  final Conversation conversation;

  @override
  ConsumerState<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends ConsumerState<ConversationPage> {
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Clear unread count for this conversation now that it's open.
    Future.microtask(() {
      if (mounted) {
        ref.read(chatRepositoryProvider).markAsRead(widget.conversation.id);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSending = true);
    final result = await ref.read(chatRepositoryProvider).sendMessage(
          conversationId: widget.conversation.id,
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

  Future<void> _deleteMessage(String messageId) async {
    final result = await ref.read(chatRepositoryProvider).deleteMessage(messageId);
    if (!mounted) return;

    result.when(
      success: (_) {},
      failure: (error) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(error)))),
    );
  }

  ConversationMember? _findMember(List<ConversationMember> members, String userId) {
    for (final member in members) {
      if (member.userId == userId) return member;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final conversation = widget.conversation;
    final theme = Theme.of(context);
    final messagesAsync = ref.watch(messagesStreamProvider(conversation.id));
    final membersAsync = ref.watch(conversationMembersProvider(conversation.id));
    final currentUserId = ref.watch(currentUserProvider)?.id;
    final members = membersAsync.value ?? const <ConversationMember>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(conversation.displayName),
        actions: [
          if (conversation.isGroup)
            IconButton(
              icon: const Icon(Icons.people_outline),
              tooltip: 'Members',
              onPressed: () => showGroupMembersSheet(context, conversation.id),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(describeError(error))),
              data: (messages) => messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet. Say hello!',
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
                        final isMine = message.senderId == currentUserId;
                        final senderName = conversation.isGroup && !isMine
                            ? _findMember(members, message.senderId)?.displayName
                            : null;

                        return MessageBubble(
                          content: message.content,
                          createdAt: message.createdAt,
                          isMine: isMine,
                          senderName: senderName,
                          onDelete: isMine ? () => _deleteMessage(message.id) : null,
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
