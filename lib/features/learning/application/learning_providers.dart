import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/learning_repository.dart';
import '../data/supabase_learning_repository.dart';
import '../domain/achievement.dart';
import '../domain/course.dart';
import '../domain/lesson.dart';
import '../domain/quiz.dart';

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  return SupabaseLearningRepository();
});

final coursesProvider = FutureProvider.autoDispose<List<Course>>((ref) {
  return ref.watch(learningRepositoryProvider).getCourses().then(
        (result) => result.when(success: (v) => v, failure: (e) => throw e),
      );
});

final lessonsProvider =
    FutureProvider.autoDispose.family<List<Lesson>, String>((ref, courseId) {
  return ref.watch(learningRepositoryProvider).getLessons(courseId).then(
        (result) => result.when(success: (v) => v, failure: (e) => throw e),
      );
});

final quizzesProvider =
    FutureProvider.autoDispose.family<List<Quiz>, String>((ref, courseId) {
  return ref.watch(learningRepositoryProvider).getQuizzes(courseId).then(
        (result) => result.when(success: (v) => v, failure: (e) => throw e),
      );
});

final myAchievementsProvider = FutureProvider.autoDispose<List<UserAchievement>>((ref) {
  return ref.watch(learningRepositoryProvider).getMyAchievements().then(
        (result) => result.when(success: (v) => v, failure: (e) => throw e),
      );
});

class QuizDetail {
  const QuizDetail({required this.questions, required this.options});

  final List<QuizQuestion> questions;
  final List<QuizAnswerOption> options;

  List<QuizAnswerOption> optionsFor(String questionId) =>
      options.where((o) => o.questionId == questionId).toList();
}

final quizDetailProvider =
    FutureProvider.autoDispose.family<QuizDetail, String>((ref, quizId) async {
  final repository = ref.watch(learningRepositoryProvider);

  final questionsResult = await repository.getQuizQuestions(quizId);
  final questions = questionsResult.when(success: (v) => v, failure: (e) => throw e);

  final optionsResult =
      await repository.getQuizAnswerOptions(questions.map((q) => q.id).toList());
  final options = optionsResult.when(success: (v) => v, failure: (e) => throw e);

  return QuizDetail(questions: questions, options: options);
});
