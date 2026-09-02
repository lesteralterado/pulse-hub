import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/learning/domain/achievement.dart';

void main() {
  group('Achievement.byCode', () {
    test('finds a known achievement', () {
      final achievement = Achievement.byCode('first_lesson');
      expect(achievement, Achievement.firstLesson);
    });

    test('returns null for an unknown code', () {
      expect(Achievement.byCode('not_a_real_code'), isNull);
    });

    test('the catalog has exactly the five achievements from the brief', () {
      expect(Achievement.all, hasLength(5));
      expect(
        Achievement.all.map((a) => a.code),
        containsAll([
          'first_lesson',
          'blockchain_beginner',
          'bot_explorer',
          'community_member',
          'course_completed',
        ]),
      );
    });
  });

  group('UserAchievement.fromMap', () {
    test('parses fields', () {
      final userAchievement = UserAchievement.fromMap({
        'achievement_code': 'first_lesson',
        'earned_at': '2026-01-01T00:00:00Z',
      });
      expect(userAchievement.achievementCode, 'first_lesson');
    });
  });
}
