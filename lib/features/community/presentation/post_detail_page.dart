import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_presenter.dart';
import '../../../core/utils/relative_time.dart';
import '../application/community_providers.dart';
import '../domain/post.dart';
import 'widgets/author_profile_sheet.dart';
import 'widgets/comment_tile.dart';

class PostDetailPage extends ConsumerStatefulWidget {
  const PostDetailPage({super.key, required this.post, required this.groupId});

  final Post post;
  final String? groupId;

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final _commentController = TextEditingController();
  bool _isSubmittingComment = false;
  bool _isTogglingLike = false;
  late bool _likedByMe = widget.post.likedByMe;
  late int _likeCount = widget.post.likeCount;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    setState(() => _isTogglingLike = true);
    final newLiked = !_likedByMe;
    final result = await ref
        .read(postRepositoryProvider)
        .setLiked(postId: widget.post.id, liked: newLiked);
    if (!mounted) return;

    result.when(
      success: (_) {
        setState(() {
          _likedByMe = newLiked;
          _likeCount += newLiked ? 1 : -1;
          _isTogglingLike = false;
        });
        ref.invalidate(feedProvider(widget.groupId));
      },
      failure: (error) {
        setState(() => _isTogglingLike = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error))));
      },
    );
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSubmittingComment = true);
    final result = await ref
        .read(postRepositoryProvider)
        .addComment(postId: widget.post.id, content: content);
    if (!mounted) return;
    setState(() => _isSubmittingComment = false);

    result.when(
      success: (_) {
        _commentController.clear();
        ref.invalidate(commentsProvider(widget.post.id));
        ref.invalidate(feedProvider(widget.groupId));
      },
      failure: (error) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(error)))),
    );
  }

  Future<void> _deleteComment(String commentId) async {
    final result = await ref.read(postRepositoryProvider).deleteComment(commentId);
    if (!mounted) return;

    result.when(
      success: (_) {
        ref.invalidate(commentsProvider(widget.post.id));
        ref.invalidate(feedProvider(widget.groupId));
      },
      failure: (error) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(error)))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;
    final commentsAsync = ref.watch(commentsProvider(post.id));
    final initial =
        post.authorDisplayName.isNotEmpty ? post.authorDisplayName[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
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
                  ],
                ),
                const SizedBox(height: 16),
                Text(post.content, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      onPressed: _isTogglingLike ? null : _toggleLike,
                      icon: Icon(
                        _likedByMe ? Icons.favorite : Icons.favorite_border,
                        color: _likedByMe ? theme.colorScheme.error : null,
                      ),
                    ),
                    Text('$_likeCount'),
                  ],
                ),
                const Divider(height: 32),
                Text('Comments', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                commentsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Text(describeError(error)),
                  data: (comments) => comments.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No comments yet.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : Column(
                          children: comments
                              .map((comment) => CommentTile(
                                    comment: comment,
                                    onDelete: () => _deleteComment(comment.id),
                                  ))
                              .toList(),
                        ),
                ),
              ],
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
                      controller: _commentController,
                      enabled: !_isSubmittingComment,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSubmittingComment ? null : _submitComment,
                    icon: _isSubmittingComment
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
