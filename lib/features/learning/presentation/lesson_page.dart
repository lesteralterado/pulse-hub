import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/error_presenter.dart';
import '../application/learning_providers.dart';
import '../domain/achievement.dart';
import '../domain/lesson.dart';

class LessonPage extends ConsumerStatefulWidget {
  const LessonPage({super.key, required this.lesson});

  final Lesson lesson;

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  bool _isMarkingComplete = false;
  late bool _isCompleted = widget.lesson.isCompleted;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(learningRepositoryProvider).markLessonViewed(widget.lesson.id);
      }
    });
  }

  Future<void> _markComplete() async {
    setState(() => _isMarkingComplete = true);
    final repository = ref.read(learningRepositoryProvider);
    final result = await repository.markLessonCompleted(widget.lesson.id);
    if (!mounted) return;

    result.when(
      success: (_) async {
        setState(() {
          _isCompleted = true;
          _isMarkingComplete = false;
        });

        final achievementsResult = await repository.checkAndAwardAchievements(
          courseId: widget.lesson.courseId,
        );
        if (!mounted) return;
        achievementsResult.when(
          success: (awarded) {
            if (awarded.isNotEmpty) _showAchievementsDialog(awarded);
          },
          failure: (_) {},
        );
      },
      failure: (error) {
        setState(() => _isMarkingComplete = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error))));
      },
    );
  }

  void _showAchievementsDialog(List<Achievement> awarded) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Achievement unlocked!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: awarded
              .map((achievement) => ListTile(
                    leading: Icon(achievement.icon),
                    title: Text(achievement.name),
                    subtitle: Text(achievement.description),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Nice!'),
          ),
        ],
      ),
    );
  }

  Future<void> _openLink() async {
    final uri = Uri.tryParse(widget.lesson.content);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: lesson.isLink
                    ? Card(
                        child: ListTile(
                          leading: const Icon(Icons.link),
                          title: Text(lesson.content),
                          trailing: const Icon(Icons.open_in_new),
                          onTap: _openLink,
                        ),
                      )
                    : Text(lesson.content, style: theme.textTheme.bodyLarge),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isCompleted || _isMarkingComplete ? null : _markComplete,
              icon: _isMarkingComplete
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_isCompleted ? Icons.check : Icons.check_circle_outline),
              label: Text(_isCompleted ? 'Completed' : 'Mark as complete'),
            ),
          ],
        ),
      ),
    );
  }
}
