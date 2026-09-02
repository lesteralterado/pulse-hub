import 'package:flutter/material.dart';

/// Definition of one of the fixed achievement types from the brief
/// (section 14). The catalog lives here, not in the database — see the
/// Phase 6 scoping discussion and the `user_achievements` check
/// constraint in supabase/migrations/0005_learning.sql, which is the
/// source of truth for valid codes.
class Achievement {
  const Achievement({
    required this.code,
    required this.name,
    required this.description,
    required this.icon,
  });

  final String code;
  final String name;
  final String description;
  final IconData icon;

  static const firstLesson = Achievement(
    code: 'first_lesson',
    name: 'First Lesson',
    description: 'Completed your first lesson.',
    icon: Icons.school_outlined,
  );

  static const blockchainBeginner = Achievement(
    code: 'blockchain_beginner',
    name: 'Blockchain Beginner',
    description: 'Completed a Blockchain Basics course.',
    icon: Icons.token_outlined,
  );

  static const botExplorer = Achievement(
    code: 'bot_explorer',
    name: 'BOT Explorer',
    description: 'Completed a BOT Chain course.',
    icon: Icons.explore_outlined,
  );

  static const communityMember = Achievement(
    code: 'community_member',
    name: 'Community Member',
    description: 'Completed a PulseHub course.',
    icon: Icons.groups_outlined,
  );

  static const courseCompleted = Achievement(
    code: 'course_completed',
    name: 'Course Completed',
    description: 'Completed an entire course.',
    icon: Icons.emoji_events_outlined,
  );

  static const all = [
    firstLesson,
    blockchainBeginner,
    botExplorer,
    communityMember,
    courseCompleted,
  ];

  static Achievement? byCode(String code) {
    for (final achievement in all) {
      if (achievement.code == code) return achievement;
    }
    return null;
  }
}

/// A row from `user_achievements`.
class UserAchievement {
  const UserAchievement({required this.achievementCode, required this.earnedAt});

  final String achievementCode;
  final DateTime earnedAt;

  factory UserAchievement.fromMap(Map<String, dynamic> map) {
    return UserAchievement(
      achievementCode: map['achievement_code'] as String,
      earnedAt: DateTime.parse(map['earned_at'] as String),
    );
  }
}
