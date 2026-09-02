import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_presenter.dart';
import '../../application/community_providers.dart';
import '../../domain/group.dart';
import '../group_detail_page.dart';

class GroupCard extends ConsumerStatefulWidget {
  const GroupCard({super.key, required this.group});

  final Group group;

  @override
  ConsumerState<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends ConsumerState<GroupCard> {
  bool _isSubmitting = false;

  Future<void> _toggleMembership() async {
    setState(() => _isSubmitting = true);
    final repository = ref.read(groupRepositoryProvider);
    final result = widget.group.isMember
        ? await repository.leaveGroup(widget.group.id)
        : await repository.joinGroup(widget.group.id);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      success: (_) => ref.invalidate(groupsProvider),
      failure: (error) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(error)))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    return Card(
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GroupDetailPage(group: group)),
        ),
        title: Text(group.name),
        subtitle: Text(
          group.description?.isNotEmpty == true
              ? group.description!
              : '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: OutlinedButton(
          onPressed: _isSubmitting ? null : _toggleMembership,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(group.isMember ? 'Leave' : 'Join'),
        ),
      ),
    );
  }
}
