import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';
import 'package:pulsehub/features/community/application/community_providers.dart';
import 'package:pulsehub/features/community/domain/post.dart';
import 'package:pulsehub/features/community/presentation/post_detail_page.dart';
import 'package:pulsehub/features/community/presentation/widgets/post_card.dart';

import '../../../../helpers/fake_auth_service.dart';
import '../../../../helpers/fake_post_repository.dart';

Post _post({required String authorId}) => Post(
      id: 'p1',
      authorId: authorId,
      groupId: null,
      postType: 'text',
      content: 'hello world',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
      authorUsername: 'alice',
      authorFullName: null,
      authorAvatarUrl: null,
      likeCount: 2,
      commentCount: 0,
      likedByMe: false,
    );

void main() {
  late FakeAuthService fakeAuthService;
  late FakePostRepository fakePostRepository;

  setUp(() {
    fakeAuthService = FakeAuthService(
      initialUser: const AppUser(id: 'u1', email: 'user@example.com', isEmailVerified: true),
    );
    fakePostRepository = FakePostRepository();
  });

  tearDown(() => fakeAuthService.dispose());

  Future<void> pumpPostCard(WidgetTester tester, Post post) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          postRepositoryProvider.overrideWithValue(fakePostRepository),
        ],
        child: MaterialApp(
          home: Scaffold(body: PostCard(post: post, groupId: null)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tapping the like button calls setLiked', (tester) async {
    await pumpPostCard(tester, _post(authorId: 'u2'));

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();

    expect(fakePostRepository.setLikedCallCount, 1);
  });

  testWidgets('tapping the card navigates to the post detail page',
      (tester) async {
    await pumpPostCard(tester, _post(authorId: 'u2'));

    await tester.tap(find.text('hello world'));
    await tester.pumpAndSettle();

    expect(find.byType(PostDetailPage), findsOneWidget);
  });

  testWidgets("own post's menu offers Edit and Delete, not Report",
      (tester) async {
    await pumpPostCard(tester, _post(authorId: 'u1'));

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Report'), findsNothing);
  });

  testWidgets("someone else's post menu offers Report, not Edit/Delete",
      (tester) async {
    await pumpPostCard(tester, _post(authorId: 'u2'));

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    expect(find.text('Report'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('deleting a post confirms, then calls deletePost',
      (tester) async {
    await pumpPostCard(tester, _post(authorId: 'u1'));

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete post?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(fakePostRepository.deletePostCallCount, 1);
  });
}
