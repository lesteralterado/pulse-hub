import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';
import 'package:pulsehub/features/community/application/community_providers.dart';
import 'package:pulsehub/features/community/domain/group.dart';
import 'package:pulsehub/features/community/presentation/group_detail_page.dart';

import '../../../helpers/fake_auth_service.dart';
import '../../../helpers/fake_group_repository.dart';
import '../../../helpers/fake_post_repository.dart';

Group _group({bool isMember = false, int memberCount = 3}) => Group(
      id: 'g1',
      name: 'BOT Chain Community',
      description: 'All things BOT Chain',
      createdBy: 'u2',
      createdAt: DateTime.utc(2026, 1, 1),
      memberCount: memberCount,
      isMember: isMember,
    );

void main() {
  late FakeAuthService fakeAuthService;
  late FakePostRepository fakePostRepository;
  late FakeGroupRepository fakeGroupRepository;

  setUp(() {
    fakeAuthService = FakeAuthService(
      initialUser: const AppUser(id: 'u1', email: 'user@example.com', isEmailVerified: true),
    );
    fakePostRepository = FakePostRepository();
    fakeGroupRepository = FakeGroupRepository();
  });

  tearDown(() => fakeAuthService.dispose());

  Future<void> pumpPage(WidgetTester tester, Group group) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          postRepositoryProvider.overrideWithValue(fakePostRepository),
          groupRepositoryProvider.overrideWithValue(fakeGroupRepository),
        ],
        child: MaterialApp(home: GroupDetailPage(group: group)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the group description and member count', (tester) async {
    await pumpPage(tester, _group());

    expect(find.text('All things BOT Chain'), findsOneWidget);
    expect(find.text('3 members'), findsOneWidget);
    expect(find.text('Join'), findsOneWidget);
  });

  testWidgets('tapping Join calls joinGroup and flips to Leave',
      (tester) async {
    await pumpPage(tester, _group(isMember: false));

    await tester.tap(find.text('Join'));
    await tester.pumpAndSettle();

    expect(fakeGroupRepository.joinGroupCallCount, 1);
    expect(find.text('Leave'), findsOneWidget);
  });

  testWidgets('tapping Leave calls leaveGroup and flips to Join',
      (tester) async {
    await pumpPage(tester, _group(isMember: true));

    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();

    expect(fakeGroupRepository.leaveGroupCallCount, 1);
    expect(find.text('Join'), findsOneWidget);
  });

  testWidgets('shows an empty state with no posts in the group',
      (tester) async {
    await pumpPage(tester, _group());

    expect(find.text('No posts in this group yet.'), findsOneWidget);
  });
}
