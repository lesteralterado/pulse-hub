import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_presenter.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../profile/domain/user_profile.dart';
import '../../application/chat_providers.dart';
import '../../domain/conversation_member.dart';
import 'user_picker_page.dart';

Future<void> showGroupMembersSheet(BuildContext context, String conversationId) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _GroupMembersSheet(conversationId: conversationId),
  );
}

class _GroupMembersSheet extends ConsumerWidget {
  const _GroupMembersSheet({required this.conversationId});

  final String conversationId;

  Future<void> _addMembers(BuildContext context, WidgetRef ref, List<ConversationMember> existing) async {
    final excludeIds = existing.map((m) => m.userId).toSet();
    final selected = await Navigator.of(context).push<List<UserProfile>>(
      MaterialPageRoute(
        builder: (_) => UserPickerPage(excludeUserIds: excludeIds),
      ),
    );
    if (selected == null || selected.isEmpty || !context.mounted) return;

    for (final profile in selected) {
      final result = await ref
          .read(chatRepositoryProvider)
          .addMember(conversationId: conversationId, userId: profile.id);
      if (result.isFailure && context.mounted) {
        result.when(
          success: (_) {},
          failure: (error) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(describeError(error)))),
        );
      }
    }
    ref.invalidate(conversationMembersProvider(conversationId));
  }

  Future<void> _removeMember(BuildContext context, WidgetRef ref, String userId) async {
    final result = await ref
        .read(chatRepositoryProvider)
        .removeMember(conversationId: conversationId, userId: userId);
    result.when(
      success: (_) => ref.invalidate(conversationMembersProvider(conversationId)),
      failure: (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(describeError(error))));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(conversationMembersProvider(conversationId));
    final currentUserId = ref.watch(currentUserProvider)?.id;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return membersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(describeError(error))),
          data: (members) {
            final myMembership = members.where((m) => m.userId == currentUserId);
            final isOwner = myMembership.isNotEmpty && myMembership.first.isOwner;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Members', style: Theme.of(context).textTheme.titleMedium),
                      if (isOwner)
                        TextButton.icon(
                          onPressed: () => _addMembers(context, ref, members),
                          icon: const Icon(Icons.person_add_alt),
                          label: const Text('Add'),
                        ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final isSelf = member.userId == currentUserId;
                        final initial = member.displayName.isNotEmpty
                            ? member.displayName[0].toUpperCase()
                            : '?';

                        return ListTile(
                          leading: CircleAvatar(child: Text(initial)),
                          title: Text(member.displayName),
                          subtitle: Text(member.isOwner ? 'Owner' : 'Member'),
                          trailing: (isOwner && !isSelf)
                              ? IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _removeMember(context, ref, member.userId),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
