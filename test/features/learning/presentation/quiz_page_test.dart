import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/learning/application/learning_providers.dart';
import 'package:pulsehub/features/learning/domain/quiz.dart';
import 'package:pulsehub/features/learning/presentation/quiz_page.dart';

import '../../../helpers/fake_learning_repository.dart';

const _quiz = Quiz(id: 'q1', courseId: 'c1', moduleId: null, title: 'Final Quiz');

void main() {
  late FakeLearningRepository fakeLearningRepository;

  setUp(() {
    fakeLearningRepository = FakeLearningRepository();
    fakeLearningRepository.questionsByQuiz['q1'] = const [
      QuizQuestion(
        id: 'qq1',
        quizId: 'q1',
        questionText: 'What does BOT Chain provide?',
        position: 0,
      ),
    ];
    fakeLearningRepository.optionsByQuestion['qq1'] = const [
      QuizAnswerOption(
        id: 'a1',
        questionId: 'qq1',
        answerText: 'A transparent ledger',
        position: 0,
      ),
      QuizAnswerOption(
        id: 'a2',
        questionId: 'qq1',
        answerText: 'A video streaming service',
        position: 1,
      ),
    ];
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [learningRepositoryProvider.overrideWithValue(fakeLearningRepository)],
        child: const MaterialApp(home: QuizPage(quiz: _quiz)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the question and its answer options', (tester) async {
    await pumpPage(tester);

    expect(find.text('What does BOT Chain provide?'), findsOneWidget);
    expect(find.text('A transparent ledger'), findsOneWidget);
    expect(find.text('A video streaming service'), findsOneWidget);
  });

  testWidgets('refuses to submit until every question is answered', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(
      find.text('Answer every question before submitting.'),
      findsOneWidget,
    );
    expect(fakeLearningRepository.submitQuizAttemptCallCount, 0);
  });

  testWidgets('submits the selected answer and shows the graded result',
      (tester) async {
    fakeLearningRepository.submitQuizAttemptResult =
        const Result.success(QuizResult(score: 1, totalQuestions: 1));
    await pumpPage(tester);

    await tester.tap(find.text('A transparent ledger'));
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(fakeLearningRepository.submitQuizAttemptCallCount, 1);
    expect(find.text('1 / 1 correct'), findsOneWidget);
    expect(find.text('Great job!'), findsOneWidget);
  });
}
