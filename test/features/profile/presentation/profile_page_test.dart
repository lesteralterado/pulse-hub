import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/config/startup_info.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';
import 'package:pulsehub/features/learning/application/learning_providers.dart';
import 'package:pulsehub/features/learning/domain/achievement.dart';
import 'package:pulsehub/features/learning/domain/course.dart';
import 'package:pulsehub/features/profile/application/profile_providers.dart';
import 'package:pulsehub/features/profile/presentation/profile_page.dart';

import '../../../helpers/fake_auth_service.dart';
import '../../../helpers/fake_learning_repository.dart';
import '../../../helpers/fake_profile_repository.dart';

void main() {
  late FakeAuthService fakeAuthService;
  late FakeProfileRepository fakeProfileRepository;
  late FakeLearningRepository fakeLearningRepository;

  setUp(() {
    fakeAuthService = FakeAuthService(
      initialUser: const AppUser(
        id: 'u1',
        email: 'user@example.com',
        isEmailVerified: true,
      ),
    );
    fakeProfileRepository = FakeProfileRepository();
    fakeLearningRepository = FakeLearningRepository();
  });

  tearDown(() => fakeAuthService.dispose());

  Future<void> pumpProfilePage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          profileRepositoryProvider.overrideWithValue(fakeProfileRepository),
          learningRepositoryProvider.overrideWithValue(fakeLearningRepository),
          startupInfoProvider.overrideWithValue(
            const StartupInfo(environment: 'test', supabaseConfigured: true),
          ),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
  }

  testWidgets('shows the signed-in email immediately, then the profile once loaded',
      (tester) async {
    await pumpProfilePage(tester);
    expect(find.text('user@example.com'), findsWidgets);

    await tester.pumpAndSettle();

    expect(find.textContaining('Joined 2026-01-01'), findsOneWidget);
    expect(fakeProfileRepository.getProfileCallCount, 1);
  });

  testWidgets('shows an error message when the profile fails to load',
      (tester) async {
    fakeProfileRepository.result = const Result.failure(
      ServerException('boom'),
    );
    await pumpProfilePage(tester);
    await tester.pumpAndSettle();

    expect(find.text('boom'), findsOneWidget);
  });

  testWidgets('shows the environment and Supabase connection status',
      (tester) async {
    await pumpProfilePage(tester);
    await tester.pumpAndSettle();

    // The About section is below the fold in the test viewport — ListView
    // doesn't build off-screen children, so scroll it into view first.
    await tester.scrollUntilVisible(
      find.text('Environment: test'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Environment: test'), findsOneWidget);
    expect(find.text('Supabase: Connected'), findsOneWidget);
  });

  testWidgets('tapping Sign out calls AuthService.signOut', (tester) async {
    await pumpProfilePage(tester);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Sign out'),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(fakeAuthService.signOutCallCount, 1);
  });

  testWidgets('shows an empty state with no achievements or progress',
      (tester) async {
    await pumpProfilePage(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('No achievements yet. Complete a lesson to earn your first one.'),
      findsOneWidget,
    );
    expect(find.text('No courses started yet.'), findsOneWidget);
  });

  testWidgets('shows earned achievements as chips', (tester) async {
    fakeLearningRepository.myAchievements = [
      UserAchievement(
        achievementCode: Achievement.firstLesson.code,
        earnedAt: DateTime.utc(2026, 1, 1),
      ),
    ];
    await pumpProfilePage(tester);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('First Lesson'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('First Lesson'), findsOneWidget);
  });

  testWidgets('shows progress bars for started courses', (tester) async {
    fakeLearningRepository.courses = [
      Course(
        id: 'c1',
        title: 'Getting Started with BOT Chain',
        description: null,
        category: 'BOT Chain',
        createdAt: DateTime.utc(2026, 1, 1),
        totalLessons: 2,
        completedLessons: 1,
      ),
    ];
    await pumpProfilePage(tester);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Getting Started with BOT Chain'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Getting Started with BOT Chain'), findsOneWidget);
  });
}
