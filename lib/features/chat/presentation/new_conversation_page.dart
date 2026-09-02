import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../core/utils/error_presenter.dart';
import '../../auth/application/auth_providers.dart';
import '../../profile/domain/user_profile.dart';
import '../application/chat_providers.dart';
import 'conversation_page.dart';
import 'widgets/user_picker_page.dart';

/// Orchestrates picking one or more people, then either opens/creates a
/// 1:1 conversation (single pick) or prompts for a group name (multiple).
/// Renders nothing of its own — it's pushed, does its thing, and either
/// replaces itself with [ConversationPage] or pops back to the list.
class NewConversationPage extends ConsumerStatefulWidget {
  const NewConversationPage({super.key});

  @override
  ConsumerState<NewConversationPage> createState() => _NewConversationPageState();
}

class _NewConversationPageState extends ConsumerState<NewConversationPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_start);
  }

  Future<void> _start() async {
    final currentUserId = ref.read(currentUserProvider)?.id;
    final selected = await Navigator.of(context).push<List<UserProfile>>(
      MaterialPageRoute(
        builder: (_) => UserPickerPage(
          excludeUserIds: currentUserId == null ? const {} : {currentUserId},
        ),
      ),
    );
    if (!mounted) return;

    if (selected == null || selected.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final result = selected.length == 1
        ? await ref
            .read(chatRepositoryProvider)
            .getOrCreateDirectConversation(selected.first.id)
        : await _promptGroupNameAndCreate(selected.map((p) => p.id).toList());

    if (!mounted || result == null) return;

    await result.when(
      success: (conversationId) => _openConversation(conversationId),
      failure: (error) async {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error))));
        Navigator.of(context).pop();
      },
    );
  }

  Future<Result<String>?> _promptGroupNameAndCreate(List<String> memberIds) async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Name this group'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Group name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(nameController.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (!mounted || name == null || name.trim().isEmpty) {
      if (mounted) Navigator.of(context).pop();
      return null;
    }

    return ref
        .read(chatRepositoryProvider)
        .createGroupConversation(name: name.trim(), memberIds: memberIds);
  }

  Future<void> _openConversation(String conversationId) async {
    ref.invalidate(conversationsProvider);
    final result = await ref.read(chatRepositoryProvider).getConversation(conversationId);
    if (!mounted) return;

    result.when(
      success: (conversation) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ConversationPage(conversation: conversation)),
        );
      },
      failure: (_) => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
