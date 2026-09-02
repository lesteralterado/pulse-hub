import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_presenter.dart';
import '../application/learning_providers.dart';
import '../domain/course.dart';
import '../domain/lesson.dart';
import 'lesson_page.dart';
import 'quiz_page.dart';
import 'widgets/lesson_tile.dart';

class CourseDetailPage extends ConsumerWidget {
  const CourseDetailPage({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsProvider(course.id));
    final quizzesAsync = ref.watch(quizzesProvider(course.id));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: lessonsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(describeError(error))),
        data: (lessons) {
          final moduleOrder = <String>[];
          final byModule = <String, List<Lesson>>{};
          for (final lesson in lessons) {
            final lessonsForModule = byModule.putIfAbsent(lesson.moduleId, () {
              moduleOrder.add(lesson.moduleId);
              return [];
            });
            lessonsForModule.add(lesson);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (course.description?.isNotEmpty ?? false) ...[
                Text(course.description!, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
              ],
              for (final moduleId in moduleOrder) ...[
                Text(byModule[moduleId]!.first.moduleTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                for (final lesson in byModule[moduleId]!)
                  LessonTile(
                    lesson: lesson,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => LessonPage(lesson: lesson)),
                      );
                      ref.invalidate(lessonsProvider(course.id));
                      ref.invalidate(coursesProvider);
                    },
                  ),
                const SizedBox(height: 16),
              ],
              quizzesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (quizzes) {
                  if (quizzes.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quizzes', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      for (final quiz in quizzes)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.quiz_outlined),
                            title: Text(quiz.title),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => QuizPage(quiz: quiz)),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
