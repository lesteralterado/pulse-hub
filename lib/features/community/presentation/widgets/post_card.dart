import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_presenter.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/community_providers.dart';
import '../../domain/post.dart';
import '../post_composer_page.dart';
import '../post_detail_page.dart';
import 'author_profile_sheet.dart';

/// One post in a feed. Owns its own like/delete/report actions (each
/// invalidates the relevant [feedProvider] on success) so callers just
/// render `PostCard(post: post, groupId: groupId)`.
class PostCard extends ConsumerStatefulWidget {
  const PostCard({super.key, required this.post, required this.groupId});

  final Post post;
  final String? groupId;

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool _isTogglingLike = false;

  Future<void> _toggleLike() async {
    setState(() => _isTogglingLike = true);
    final result = await ref.read(postRepositoryProvider).setLiked(
          postId: widget.post.id,
          liked: !widget.post.likedByMe,
        );
    if (!mounted) return;
    setState(() => _isTogglingLike = false);

    result.when(
      success: (_) => ref.invalidate(feedProvider(widget.groupId)),
      failure: (error) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(error)))),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await ref.read(postRepositoryProvider).deletePost(widget.post.id);
    if (!mounted) return;

    result.when(
      success: (_) => ref.invalidate(feedProvider(widget.groupId)),
      failure: (error) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(error)))),
    );
  }

  Future<void> _report() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report post'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Reason'),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (reason == null || reason.trim().isEmpty || !mounted) return;

    final result = await ref
        .read(postRepositoryProvider)
        .reportPost(postId: widget.post.id, reason: reason.trim());
    if (!mounted) return;

    result.when(
      success: (_) => ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Report submitted.'))),
      failure: (error) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(error)))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final theme = Theme.of(context);
    final isOwner = ref.watch(currentUserProvider)?.id == post.authorId;
    final initial =
        post.authorDisplayName.isNotEmpty ? post.authorDisplayName[0].toUpperCase() : '?';

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PostDetailPage(post: post, groupId: widget.groupId),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => showAuthorProfileSheet(context, post.authorId),
                    child: CircleAvatar(child: Text(initial)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => showAuthorProfileSheet(context, post.authorId),
                          child: Text(
                            post.authorDisplayName,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        Text(
                          formatRelativeTime(post.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PostComposerPage(
                                groupId: widget.groupId,
                                existingPost: post,
                              ),
                            ),
                          );
                        case 'delete':
                          _delete();
                        case 'report':
                          _report();
                      }
                    },
                    itemBuilder: (context) => [
                      if (isOwner)
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      if (isOwner)
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      if (!isOwner)
                        const PopupMenuItem(value: 'report', child: Text('Report')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(post.content, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: _isTogglingLike ? null : _toggleLike,
                    icon: Icon(
                      post.likedByMe ? Icons.favorite : Icons.favorite_border,
                      color: post.likedByMe ? theme.colorScheme.error : null,
                    ),
                  ),
                  Text('${post.likeCount}'),
                  const SizedBox(width: 16),
                  const Icon(Icons.mode_comment_outlined, size: 20),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
