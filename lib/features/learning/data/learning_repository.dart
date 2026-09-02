import '../../../core/errors/result.dart';
import '../domain/achievement.dart';
import '../domain/course.dart';
import '../domain/lesson.dart';
import '../domain/quiz.dart';

/// Kept as an interface (implemented by [SupabaseLearningRepository]) so
/// widget/provider tests can substitute a fake instead of hitting a real
/// Supabase project — same pattern as the other repositories.
abstract class LearningRepository {
  Future<Result<List<Course>>> getCourses();

  /// All lessons for a course, grouped by module client-side using each
  /// lesson's [Lesson.moduleTitle]/[Lesson.modulePosition].
  Future<Result<List<Lesson>>> getLessons(String courseId);

  Future<Result<void>> markLessonViewed(String lessonId);

  Future<Result<void>> markLessonCompleted(String lessonId);

  /// After marking a lesson complete, checks the fixed achievement rules
  /// and awards any newly-qualified ones. Returns just the ones awarded
  /// by this call (empty if none), so the UI can celebrate them.
  Future<Result<List<Achievement>>> checkAndAwardAchievements({
    required String courseId,
  });

  Future<Result<List<Quiz>>> getQuizzes(String courseId);

  Future<Result<List<QuizQuestion>>> getQuizQuestions(String quizId);

  Future<Result<List<QuizAnswerOption>>> getQuizAnswerOptions(
    List<String> questionIds,
  );

  /// [answers] maps question id -> selected answer id. Grading happens
  /// server-side (grade_quiz_attempt), so the result is trustworthy.
  Future<Result<QuizResult>> submitQuizAttempt({
    required String quizId,
    required Map<String, String> answers,
  });

  Future<Result<List<UserAchievement>>> getMyAchievements();
}
