import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/learning/domain/course.dart';

Map<String, dynamic> _row({int totalLessons = 0, int completedLessons = 0}) {
  return {
    'id': 'c1',
    'title': 'Getting Started with BOT Chain',
    'description': 'An intro course',
    'category': 'BOT Chain',
    'created_at': '2026-01-01T00:00:00Z',
    'total_lessons': totalLessons,
    'completed_lessons': completedLessons,
  };
}

void main() {
  group('Course.fromMap', () {
    test('parses all fields', () {
      final course = Course.fromMap(_row(totalLessons: 4, completedLessons: 2));
      expect(course.id, 'c1');
      expect(course.category, 'BOT Chain');
      expect(course.totalLessons, 4);
      expect(course.completedLessons, 2);
    });

    test('a course with no completed lessons is not started', () {
      final course = Course.fromMap(_row(totalLessons: 4, completedLessons: 0));
      expect(course.isStarted, isFalse);
      expect(course.isCompleted, isFalse);
    });

    test('a course with some but not all lessons complete is started, not done', () {
      final course = Course.fromMap(_row(totalLessons: 4, completedLessons: 2));
      expect(course.isStarted, isTrue);
      expect(course.isCompleted, isFalse);
      expect(course.completionRatio, 0.5);
    });

    test('a course with every lesson complete is done', () {
      final course = Course.fromMap(_row(totalLessons: 4, completedLessons: 4));
      expect(course.isCompleted, isTrue);
      expect(course.completionRatio, 1.0);
    });

    test('an empty course has a zero completion ratio, not a division error', () {
      final course = Course.fromMap(_row(totalLessons: 0, completedLessons: 0));
      expect(course.completionRatio, 0);
      expect(course.isCompleted, isFalse);
    });
  });
}
