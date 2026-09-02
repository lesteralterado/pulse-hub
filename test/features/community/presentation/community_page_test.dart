import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';
import 'package:pulsehub/features/community/application/community_providers.dart';
import 'package:pulsehub/features/community/domain/group.dart';
import 'package:pulsehub/features/community/domain/post.dart';
import 'package:pulsehub/features/community/presentation/community_page.dart';
import 'package:pulsehub/features/community/presentation/create_group_page.dart';
import 'package:pulsehub/features/community/presentation/post_composer_page.dart';

import '../../../helpers/fake_auth_service.dart';
import '../../../helpers/fake_group_repository.dart';
import '../../../helpers/fake_post_repository.dart';

Post _post({String? groupId}) => Post(
      id: 'p1',
      authorId: 'u1',
      groupId: groupId,
      postType: 'text',
      content: 'hello world',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
      authorUsername: 'alice',
      authorFullName: null,
      authorAvatarUrl: null,
      likeCount: 0,
      commentCount: 0,
      likedByMe: false,
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

  Future<void> pumpCommunityPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          postRepositoryProvider.overrideWithValue(fakePostRepository),
          groupRepositoryProvider.overrideWithValue(fakeGroupRepository),
        ],
        child: const MaterialApp(home: CommunityPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Feed tab shows an empty state with no posts', (tester) async {
    await pumpCommunityPage(tester);

    expect(find.text('No posts yet. Be the first to share something.'), findsOneWidget);
  });

  testWidgets('Feed tab lists posts from the general feed', (tester) async {
    fakePostRepository.feed = [_post()];
    await pumpCommunityPage(tester);

    expect(find.text('hello world'), findsOneWidget);
    expect(find.text('alice'), findsOneWidget);
  });

  testWidgets('Feed FAB opens the post composer', (tester) async {
    await pumpCommunityPage(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(PostComposerPage), findsOneWidget);
  });

  testWidgets('Groups tab shows an empty state with no groups', (tester) async {
    await pumpCommunityPage(tester);

    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();

    expect(find.text('No groups yet. Start one for your topic.'), findsOneWidget);
  });

  testWidgets('Groups tab lists groups and their member counts', (tester) async {
    fakeGroupRepository.groups = [
      Group(
        id: 'g1',
        name: 'BOT Chain Community',
        description: null,
        createdBy: 'u2',
        createdAt: DateTime.utc(2026, 1, 1),
        memberCount: 5,
        isMember: false,
      ),
    ];
    await pumpCommunityPage(tester);

    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();

    expect(find.text('BOT Chain Community'), findsOneWidget);
    expect(find.text('5 members'), findsOneWidget);
    expect(find.text('Join'), findsOneWidget);
  });

  testWidgets('Groups FAB opens the create-group page', (tester) async {
    await pumpCommunityPage(tester);

    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(CreateGroupPage), findsOneWidget);
  });
}
