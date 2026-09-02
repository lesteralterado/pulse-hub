import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_presenter.dart';
import '../application/community_providers.dart';
import '../domain/group.dart';
import 'post_composer_page.dart';
import 'widgets/post_card.dart';

class GroupDetailPage extends ConsumerStatefulWidget {
  const GroupDetailPage({super.key, required this.group});

  final Group group;

  @override
  ConsumerState<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends ConsumerState<GroupDetailPage> {
  bool _isSubmitting = false;
  late bool _isMember = widget.group.isMember;

  Future<void> _toggleMembership() async {
    setState(() => _isSubmitting = true);
    final repository = ref.read(groupRepositoryProvider);
    final result = _isMember
        ? await repository.leaveGroup(widget.group.id)
        : await repository.joinGroup(widget.group.id);
    if (!mounted) return;

    result.when(
      success: (_) {
        setState(() {
          _isMember = !_isMember;
          _isSubmitting = false;
        });
        ref.invalidate(groupsProvider);
      },
      failure: (error) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error))));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final theme = Theme.of(context);
    final feedAsync = ref.watch(feedProvider(group.id));

    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PostComposerPage(groupId: group.id),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(feedProvider(group.id)),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (group.description?.isNotEmpty == true) ...[
                      Text(group.description!, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        OutlinedButton(
                          onPressed: _isSubmitting ? null : _toggleMembership,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_isMember ? 'Leave' : 'Join'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            feedAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text(describeError(error))),
              ),
              data: (posts) => posts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'No posts in this group yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: posts
                          .map((post) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: PostCard(post: post, groupId: group.id),
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
