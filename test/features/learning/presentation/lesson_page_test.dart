import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/learning/application/learning_providers.dart';
import 'package:pulsehub/features/learning/domain/achievement.dart';
import 'package:pulsehub/features/learning/domain/lesson.dart';
import 'package:pulsehub/features/learning/presentation/lesson_page.dart';

import '../../../helpers/fake_learning_repository.dart';

final _textLesson = Lesson(
  id: 'l1',
  moduleId: 'm1',
  title: 'What is BOT Chain?',
  contentType: 'text',
  content: 'BOT Chain is a blockchain network.',
  lessonPosition: 0,
  courseId: 'c1',
  moduleTitle: 'The Basics',
  modulePosition: 0,
  viewedAt: null,
  completedAt: null,
);

final _linkLesson = Lesson(
  id: 'l2',
  moduleId: 'm1',
  title: 'BOT Chain docs',
  contentType: 'link',
  content: 'https://example.com/docs',
  lessonPosition: 1,
  courseId: 'c1',
  moduleTitle: 'The Basics',
  modulePosition: 0,
  viewedAt: null,
  completedAt: null,
);

void main() {
  late FakeLearningRepository fakeLearningRepository;

  setUp(() {
    fakeLearningRepository = FakeLearningRepository();
  });

  Future<void> pumpPage(WidgetTester tester, Lesson lesson) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [learningRepositoryProvider.overrideWithValue(fakeLearningRepository)],
        child: MaterialApp(home: LessonPage(lesson: lesson)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('marks the lesson viewed on open', (tester) async {
    await pumpPage(tester, _textLesson);
    expect(fakeLearningRepository.markLessonViewedCallCount, 1);
  });

  testWidgets('shows the text content for a text lesson', (tester) async {
    await pumpPage(tester, _textLesson);
    expect(find.text('BOT Chain is a blockchain network.'), findsOneWidget);
  });

  testWidgets('shows the URL for a link lesson', (tester) async {
    await pumpPage(tester, _linkLesson);
    expect(find.text('https://example.com/docs'), findsOneWidget);
  });

  testWidgets('tapping Mark as complete calls markLessonCompleted and disables itself',
      (tester) async {
    await pumpPage(tester, _textLesson);

    await tester.tap(find.text('Mark as complete'));
    await tester.pumpAndSettle();

    expect(fakeLearningRepository.markLessonCompletedCallCount, 1);
    expect(fakeLearningRepository.checkAndAwardAchievementsCallCount, 1);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Mark as complete'), findsNothing);
  });

  testWidgets('shows an achievement dialog when one is newly awarded',
      (tester) async {
    fakeLearningRepository.checkAndAwardAchievementsResult =
        const Result.success([Achievement.firstLesson]);
    await pumpPage(tester, _textLesson);

    await tester.tap(find.text('Mark as complete'));
    await tester.pumpAndSettle();

    expect(find.text('Achievement unlocked!'), findsOneWidget);
    expect(find.text('First Lesson'), findsOneWidget);
  });
}
