import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/learning/domain/quiz.dart';

void main() {
  group('Quiz.fromMap', () {
    test('a null module_id means a final quiz', () {
      final quiz = Quiz.fromMap({
        'id': 'q1',
        'course_id': 'c1',
        'module_id': null,
        'title': 'Final Quiz',
      });
      expect(quiz.isFinalQuiz, isTrue);
    });

    test('a set module_id means a per-module quiz', () {
      final quiz = Quiz.fromMap({
        'id': 'q1',
        'course_id': 'c1',
        'module_id': 'm1',
        'title': 'Module Quiz',
      });
      expect(quiz.isFinalQuiz, isFalse);
    });
  });

  group('QuizQuestion.fromMap', () {
    test('parses fields', () {
      final question = QuizQuestion.fromMap({
        'id': 'qq1',
        'quiz_id': 'q1',
        'question_text': 'What does BOT Chain provide?',
        'position': 0,
      });
      expect(question.questionText, 'What does BOT Chain provide?');
    });
  });

  group('QuizAnswerOption.fromMap', () {
    test('parses fields without an isCorrect field', () {
      final option = QuizAnswerOption.fromMap({
        'id': 'a1',
        'question_id': 'qq1',
        'answer_text': 'A transparent ledger',
        'position': 0,
      });
      expect(option.answerText, 'A transparent ledger');
    });
  });

  group('QuizResult', () {
    test('a perfect score passes', () {
      final result = QuizResult.fromMap({'score': 3, 'total_questions': 3});
      expect(result.passed, isTrue);
    });

    test('a partial score does not pass', () {
      final result = QuizResult.fromMap({'score': 2, 'total_questions': 3});
      expect(result.passed, isFalse);
    });

    test('zero questions does not pass (no false positive)', () {
      final result = QuizResult.fromMap({'score': 0, 'total_questions': 0});
      expect(result.passed, isFalse);
    });
  });
}
