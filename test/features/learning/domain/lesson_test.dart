import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/learning/domain/lesson.dart';

Map<String, dynamic> _row({
  String contentType = 'text',
  String? completedAt,
}) {
  return {
    'id': 'l1',
    'module_id': 'm1',
    'title': 'What is BOT Chain?',
    'content_type': contentType,
    'content': 'Some content',
    'lesson_position': 0,
    'course_id': 'c1',
    'module_title': 'The Basics',
    'module_position': 0,
    'viewed_at': null,
    'completed_at': completedAt,
  };
}

void main() {
  group('Lesson.fromMap', () {
    test('parses all fields', () {
      final lesson = Lesson.fromMap(_row());
      expect(lesson.id, 'l1');
      expect(lesson.moduleTitle, 'The Basics');
      expect(lesson.courseId, 'c1');
    });

    test('a text lesson is not a link', () {
      final lesson = Lesson.fromMap(_row(contentType: 'text'));
      expect(lesson.isLink, isFalse);
    });

    test('a link lesson is a link', () {
      final lesson = Lesson.fromMap(_row(contentType: 'link'));
      expect(lesson.isLink, isTrue);
    });

    test('completedAt null means not completed', () {
      final lesson = Lesson.fromMap(_row(completedAt: null));
      expect(lesson.isCompleted, isFalse);
    });

    test('a set completedAt means completed', () {
      final lesson = Lesson.fromMap(_row(completedAt: '2026-01-02T00:00:00Z'));
      expect(lesson.isCompleted, isTrue);
    });
  });
}
