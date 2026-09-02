import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/learning/application/learning_providers.dart';
import 'package:pulsehub/features/learning/domain/course.dart';
import 'package:pulsehub/features/learning/domain/lesson.dart';
import 'package:pulsehub/features/learning/domain/quiz.dart';
import 'package:pulsehub/features/learning/presentation/course_detail_page.dart';
import 'package:pulsehub/features/learning/presentation/lesson_page.dart';
import 'package:pulsehub/features/learning/presentation/quiz_page.dart';

import '../../../helpers/fake_learning_repository.dart';

final _course = Course(
  id: 'c1',
  title: 'Getting Started with BOT Chain',
  description: 'An intro course',
  category: 'BOT Chain',
  createdAt: DateTime.utc(2026, 1, 1),
  totalLessons: 2,
  completedLessons: 0,
);

Lesson _lesson({required String id, required int lessonPosition}) {
  return Lesson(
    id: id,
    moduleId: 'm1',
    title: 'Lesson $lessonPosition',
    contentType: 'text',
    content: 'Some content',
    lessonPosition: lessonPosition,
    courseId: 'c1',
    moduleTitle: 'The Basics',
    modulePosition: 0,
    viewedAt: null,
    completedAt: null,
  );
}

void main() {
  late FakeLearningRepository fakeLearningRepository;

  setUp(() {
    fakeLearningRepository = FakeLearningRepository();
    fakeLearningRepository.lessonsByCourse['c1'] = [
      _lesson(id: 'l1', lessonPosition: 0),
      _lesson(id: 'l2', lessonPosition: 1),
    ];
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [learningRepositoryProvider.overrideWithValue(fakeLearningRepository)],
        child: MaterialApp(home: CourseDetailPage(course: _course)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('groups lessons under their module heading', (tester) async {
    await pumpPage(tester);

    expect(find.text('The Basics'), findsOneWidget);
    expect(find.text('Lesson 0'), findsOneWidget);
    expect(find.text('Lesson 1'), findsOneWidget);
  });

  testWidgets('tapping a lesson opens the lesson page', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Lesson 0'));
    await tester.pumpAndSettle();

    expect(find.byType(LessonPage), findsOneWidget);
  });

  testWidgets('shows quizzes when the course has any', (tester) async {
    fakeLearningRepository.quizzesByCourse['c1'] = [
      const Quiz(id: 'q1', courseId: 'c1', moduleId: null, title: 'Final Quiz'),
    ];
    await pumpPage(tester);

    expect(find.text('Quizzes'), findsOneWidget);
    expect(find.text('Final Quiz'), findsOneWidget);

    await tester.tap(find.text('Final Quiz'));
    await tester.pumpAndSettle();

    expect(find.byType(QuizPage), findsOneWidget);
  });

  testWidgets('shows no quiz section when the course has none', (tester) async {
    await pumpPage(tester);
    expect(find.text('Quizzes'), findsNothing);
  });
}
