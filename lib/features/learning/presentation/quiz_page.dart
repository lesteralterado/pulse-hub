import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_presenter.dart';
import '../application/learning_providers.dart';
import '../domain/quiz.dart';

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({super.key, required this.quiz});

  final Quiz quiz;

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  final Map<String, String> _selectedAnswers = {};
  bool _isSubmitting = false;
  QuizResult? _result;

  Future<void> _submit(int questionCount) async {
    if (_selectedAnswers.length < questionCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answer every question before submitting.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await ref.read(learningRepositoryProvider).submitQuizAttempt(
          quizId: widget.quiz.id,
          answers: _selectedAnswers,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      success: (quizResult) => setState(() => _result = quizResult),
      failure: (error) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(error)))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detailAsync = ref.watch(quizDetailProvider(widget.quiz.id));

    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title)),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(describeError(error))),
        data: (detail) {
          if (_result != null) {
            return _ResultView(result: _result!);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final question in detail.questions) ...[
                Text(question.questionText, style: theme.textTheme.titleMedium),
                RadioGroup<String>(
                  groupValue: _selectedAnswers[question.id],
                  onChanged: (value) {
                    if (_isSubmitting || value == null) return;
                    setState(() => _selectedAnswers[question.id] = value);
                  },
                  child: Column(
                    children: [
                      for (final option in detail.optionsFor(question.id))
                        RadioListTile<String>(
                          value: option.id,
                          title: Text(option.answerText),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              FilledButton(
                onPressed: _isSubmitting ? null : () => _submit(detail.questions.length),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result});

  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              result.passed ? Icons.emoji_events_outlined : Icons.replay,
              size: 56,
              color: result.passed ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '${result.score} / ${result.totalQuestions} correct',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              result.passed ? 'Great job!' : 'Review the lessons and try again.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to course'),
            ),
          ],
        ),
      ),
    );
  }
}
