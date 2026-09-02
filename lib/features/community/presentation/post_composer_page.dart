import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_presenter.dart';
import '../application/community_providers.dart';
import '../domain/post.dart';

/// Create or edit a post. Text-only for this phase — image/video post
/// types exist in the schema but need Supabase Storage wiring, deferred.
class PostComposerPage extends ConsumerStatefulWidget {
  const PostComposerPage({super.key, this.groupId, this.existingPost});

  /// The group to post into, or null for the general feed.
  final String? groupId;

  /// When set, edits this post instead of creating a new one.
  final Post? existingPost;

  @override
  ConsumerState<PostComposerPage> createState() => _PostComposerPageState();
}

class _PostComposerPageState extends ConsumerState<PostComposerPage> {
  late final _controller = TextEditingController(
    text: widget.existingPost?.content ?? '',
  );
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isEditing => widget.existingPost != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      setState(() => _errorMessage = 'Write something before posting.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final repository = ref.read(postRepositoryProvider);
    final result = _isEditing
        ? await repository.updatePost(
            postId: widget.existingPost!.id,
            content: content,
          )
        : await repository.createPost(content: content, groupId: widget.groupId);

    if (!mounted) return;

    result.when(
      success: (_) {
        ref.invalidate(feedProvider(widget.groupId));
        Navigator.of(context).pop();
      },
      failure: (error) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = describeError(error);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit post' : 'New post'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'Save' : 'Post'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _controller,
              maxLines: 10,
              minLines: 5,
              maxLength: 5000,
              enabled: !_isSubmitting,
              autofocus: !_isEditing,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
