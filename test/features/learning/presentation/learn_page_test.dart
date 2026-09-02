import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/learning/application/learning_providers.dart';
import 'package:pulsehub/features/learning/domain/course.dart';
import 'package:pulsehub/features/learning/presentation/course_detail_page.dart';
import 'package:pulsehub/features/learning/presentation/learn_page.dart';

import '../../../helpers/fake_learning_repository.dart';

Course _course({required String id, required String title, required String category}) {
  return Course(
    id: id,
    title: title,
    description: null,
    category: category,
    createdAt: DateTime.utc(2026, 1, 1),
    totalLessons: 2,
    completedLessons: 0,
  );
}

void main() {
  late FakeLearningRepository fakeLearningRepository;

  setUp(() {
    fakeLearningRepository = FakeLearningRepository();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [learningRepositoryProvider.overrideWithValue(fakeLearningRepository)],
        child: const MaterialApp(home: LearnPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows an empty state with no courses', (tester) async {
    await pumpPage(tester);
    expect(find.text('No courses available yet.'), findsOneWidget);
  });

  testWidgets('lists courses grouped by category', (tester) async {
    fakeLearningRepository.courses = [
      _course(id: 'c1', title: 'Getting Started with BOT Chain', category: 'BOT Chain'),
      _course(id: 'c2', title: 'What is CaryPact?', category: 'CaryPact'),
    ];
    await pumpPage(tester);

    expect(find.text('BOT Chain'), findsOneWidget);
    expect(find.text('CaryPact'), findsOneWidget);
    expect(find.text('Getting Started with BOT Chain'), findsOneWidget);
    expect(find.text('What is CaryPact?'), findsOneWidget);
  });

  testWidgets('tapping a course opens its detail page', (tester) async {
    fakeLearningRepository.courses = [
      _course(id: 'c1', title: 'Getting Started with BOT Chain', category: 'BOT Chain'),
    ];
    await pumpPage(tester);

    await tester.tap(find.text('Getting Started with BOT Chain'));
    await tester.pumpAndSettle();

    expect(find.byType(CourseDetailPage), findsOneWidget);
  });
}
