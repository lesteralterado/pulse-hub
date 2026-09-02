import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../../../services/supabase/supabase_service.dart';
import '../domain/achievement.dart';
import '../domain/course.dart';
import '../domain/lesson.dart';
import '../domain/quiz.dart';
import 'learning_repository.dart';

class SupabaseLearningRepository implements LearningRepository {
  String get _requireUserId {
    final id = SupabaseService.client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('SupabaseLearningRepository used while signed out');
    }
    return id;
  }

  @override
  Future<Result<List<Course>>> getCourses() async {
    try {
      final rows = await SupabaseService.client
          .from('course_summary')
          .select()
          .order('category')
          .order('title');
      return Result.success(rows.map(Course.fromMap).toList());
    } catch (error) {
      return Result.failure(mapLearningError(error));
    }
  }

  @override
  Future<Result<List<Lesson>>> getLessons(String courseId) async {
    try {
      final rows = await SupabaseService.client
          .from('lesson_summary')
          .select()
          .eq('course_id', courseId)
          .order('module_position')
          .order('lesson_position');
      return Result.success(rows.map(Lesson.fromMap).toList());
    } catch (error) {
      return Result.failure(mapLearningError(error));
    }
  }

  @override
  Future<Result<void>> markLessonViewed(String lessonId) async {
    try {
      await SupabaseService.client.from('user_progress').upsert(
        {
          'user_id': _requireUserId,
          'lesson_id': lessonId,
          'viewed_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'user_id,lesson_id',
      );
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapLearningError(error));
    }
  }

  @override
  Future<Result<void>> markLessonCompleted(String lessonId) async {
    try {
      await SupabaseService.client.from('user_progress').upsert(
        {
          'user_id': _requireUserId,
          'lesson_id': lessonId,
          'viewed_at': DateTime.now().toUtc().toIso8601String(),
          'completed_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'user_id,lesson_id',
      );
      return const Result.success(null);
    } catch (error) {
      return Result.failure(mapLearningError(error));
    }
  }

  @override
  Future<Result<List<Achievement>>> checkAndAwardAchievements({
    required String courseId,
  }) async {
    try {
      final userId = _requireUserId;

      final alreadyEarnedRows = await SupabaseService.client
          .from('user_achievements')
          .select('achievement_code')
          .eq('user_id', userId);
      final alreadyEarned =
          alreadyEarnedRows.map((row) => row['achievement_code'] as String).toSet();

      final toAward = <String>{};

      final completedAnyLesson = await SupabaseService.client
          .from('user_progress')
          .select('id')
          .eq('user_id', userId)
          .not('completed_at', 'is', null)
          .limit(1);
      if (completedAnyLesson.isNotEmpty && !alreadyEarned.contains('first_lesson')) {
        toAward.add('first_lesson');
      }

      final courseRow = await SupabaseService.client
          .from('course_summary')
          .select()
          .eq('id', courseId)
          .single();
      final course = Course.fromMap(courseRow);
      if (course.isCompleted) {
        if (!alreadyEarned.contains('course_completed')) {
          toAward.add('course_completed');
        }
        final categoryCode = _achievementCodeForCategory(course.category);
        if (categoryCode != null && !alreadyEarned.contains(categoryCode)) {
          toAward.add(categoryCode);
        }
      }

      if (toAward.isEmpty) return const Result.success([]);

      await SupabaseService.client.from('user_achievements').insert(
        toAward.map((code) => {'user_id': userId, 'achievement_code': code}).toList(),
      );

      return Result.success(
        toAward.map(Achievement.byCode).whereType<Achievement>().toList(),
      );
    } catch (error) {
      return Result.failure(mapLearningError(error));
    }
  }

  String? _achievementCodeForCategory(String category) {
    switch (category) {
      case 'Blockchain Basics':
        return 'blockchain_beginner';
      case 'BOT Chain':
        return 'bot_explorer';
      case 'PulseHub':
        return 'community_member';
      default:
        return null;
    }
  }

  @override
  Future<Result<List<Quiz>>> getQuizzes(String courseId) async {
    try {
      final rows = await SupabaseService.client
          .from('quizzes')
          .select()
          .eq('course_id', courseId);
      return Result.success(rows.map(Quiz.fromMap).toList());
    } catch (error) {
      return Result.failure(mapLearningError(error));
    }
  }

  @override
  Future<Result<List<QuizQuestion>>> getQuizQuestions(String quizId) async {
    try {
      final rows = await SupabaseService.client
          .from('quiz_questions')
          .select()
          .eq('quiz_id', quizId)
          .order('position');
      return Result.success(rows.map(QuizQuestion.fromMap).toList());
    } catch (error) {
      return Result.failure(mapLearningError(error));
    }
  }

  @override
  Future<Result<List<QuizAnswerOption>>> getQuizAnswerOptions(
    List<String> questionIds,
  ) async {
    try {
      if (questionIds.isEmpty) return const Result.success([]);
      final rows = await SupabaseService.client
          .from('quiz_answer_options')
          .select()
          .inFilter('question_id', questionIds)
          .order('position');
      return Result.success(rows.map(QuizAnswerOption.fromMap).toList());
    } catch (error) {
      return Result.failure(mapLearningError(error));
    }
  }

  @override
  Future<Result<QuizResult>> submitQuizAttempt({
    required String quizId,
    required Map<String, String> answers,
  }) async {
    try {
      final row = await SupabaseService.client.rpc(
        'grade_quiz_attempt',
        params: {'p_quiz_id': quizId, 'p_answers': answers},
      ).single();
      return Result.success(QuizResult.fromMap(row));
    } catch (error) {
      return Result.failure(mapLearningError(error));
    }
  }

  @override
  Future<Result<List<UserAchievement>>> getMyAchievements() async {
    try {
      final rows = await SupabaseService.client
          .from('user_achievements')
          .select()
          .eq('user_id', _requireUserId)
          .order('earned_at', ascending: false);
      return Result.success(rows.map(UserAchievement.fromMap).toList());
    } catch (error) {
      return Result.failure(mapLearningError(error));
    }
  }

  /// Extracted as a standalone function so error-mapping can be unit
  /// tested without needing a live Supabase connection.
  static AppException mapLearningError(Object error) {
    if (error is supabase.PostgrestException) {
      return ServerException(error.message, cause: error);
    }
    return UnknownException('Unexpected learning error: $error', cause: error);
  }
}
