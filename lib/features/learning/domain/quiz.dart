/// A row from the `quizzes` table. [moduleId] is null for a course's
/// final quiz, set for a per-module quiz.
class Quiz {
  const Quiz({
    required this.id,
    required this.courseId,
    required this.moduleId,
    required this.title,
  });

  final String id;
  final String courseId;
  final String? moduleId;
  final String title;

  bool get isFinalQuiz => moduleId == null;

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] as String,
      courseId: map['course_id'] as String,
      moduleId: map['module_id'] as String?,
      title: map['title'] as String,
    );
  }
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.position,
  });

  final String id;
  final String quizId;
  final String questionText;
  final int position;

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] as String,
      quizId: map['quiz_id'] as String,
      questionText: map['question_text'] as String,
      position: map['position'] as int,
    );
  }
}

/// From the `quiz_answer_options` view -- deliberately has no
/// `isCorrect` field, since that view never exposes it (see
/// supabase/migrations/0005_learning.sql).
class QuizAnswerOption {
  const QuizAnswerOption({
    required this.id,
    required this.questionId,
    required this.answerText,
    required this.position,
  });

  final String id;
  final String questionId;
  final String answerText;
  final int position;

  factory QuizAnswerOption.fromMap(Map<String, dynamic> map) {
    return QuizAnswerOption(
      id: map['id'] as String,
      questionId: map['question_id'] as String,
      answerText: map['answer_text'] as String,
      position: map['position'] as int,
    );
  }
}

/// The result of `grade_quiz_attempt()` -- grading happens server-side,
/// so this is trustworthy even though the client picked the answers.
class QuizResult {
  const QuizResult({required this.score, required this.totalQuestions});

  final int score;
  final int totalQuestions;

  bool get passed => totalQuestions > 0 && score == totalQuestions;

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      score: map['score'] as int,
      totalQuestions: map['total_questions'] as int,
    );
  }
}
