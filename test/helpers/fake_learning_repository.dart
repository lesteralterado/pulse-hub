import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/learning/data/learning_repository.dart';
import 'package:pulsehub/features/learning/domain/achievement.dart';
import 'package:pulsehub/features/learning/domain/course.dart';
import 'package:pulsehub/features/learning/domain/lesson.dart';
import 'package:pulsehub/features/learning/domain/quiz.dart';

/// In-memory [LearningRepository] double for widget/provider tests, so
/// nothing in the test suite ever touches a real Supabase project.
class FakeLearningRepository implements LearningRepository {
  List<Course> courses = [];
  Map<String, List<Lesson>> lessonsByCourse = {};
  Map<String, List<Quiz>> quizzesByCourse = {};
  Map<String, List<QuizQuestion>> questionsByQuiz = {};
  Map<String, List<QuizAnswerOption>> optionsByQuestion = {};
  List<UserAchievement> myAchievements = [];

  Result<void>? markLessonViewedResult;
  Result<void>? markLessonCompletedResult;
  Result<List<Achievement>>? checkAndAwardAchievementsResult;
  Result<QuizResult>? submitQuizAttemptResult;

  int markLessonViewedCallCount = 0;
  int markLessonCompletedCallCount = 0;
  int checkAndAwardAchievementsCallCount = 0;
  int submitQuizAttemptCallCount = 0;

  @override
  Future<Result<List<Course>>> getCourses() async => Result.success(courses);

  @override
  Future<Result<List<Lesson>>> getLessons(String courseId) async {
    return Result.success(lessonsByCourse[courseId] ?? []);
  }

  @override
  Future<Result<void>> markLessonViewed(String lessonId) async {
    markLessonViewedCallCount++;
    return markLessonViewedResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> markLessonCompleted(String lessonId) async {
    markLessonCompletedCallCount++;
    return markLessonCompletedResult ?? const Result.success(null);
  }

  @override
  Future<Result<List<Achievement>>> checkAndAwardAchievements({
    required String courseId,
  }) async {
    checkAndAwardAchievementsCallCount++;
    return checkAndAwardAchievementsResult ?? const Result.success([]);
  }

  @override
  Future<Result<List<Quiz>>> getQuizzes(String courseId) async {
    return Result.success(quizzesByCourse[courseId] ?? []);
  }

  @override
  Future<Result<List<QuizQuestion>>> getQuizQuestions(String quizId) async {
    return Result.success(questionsByQuiz[quizId] ?? []);
  }

  @override
  Future<Result<List<QuizAnswerOption>>> getQuizAnswerOptions(
    List<String> questionIds,
  ) async {
    final options = <QuizAnswerOption>[];
    for (final questionId in questionIds) {
      options.addAll(optionsByQuestion[questionId] ?? []);
    }
    return Result.success(options);
  }

  @override
  Future<Result<QuizResult>> submitQuizAttempt({
    required String quizId,
    required Map<String, String> answers,
  }) async {
    submitQuizAttemptCallCount++;
    return submitQuizAttemptResult ??
        const Result.success(QuizResult(score: 1, totalQuestions: 1));
  }

  @override
  Future<Result<List<UserAchievement>>> getMyAchievements() async {
    return Result.success(myAchievements);
  }
}
