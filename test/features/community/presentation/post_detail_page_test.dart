import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';
import 'package:pulsehub/features/community/application/community_providers.dart';
import 'package:pulsehub/features/community/domain/comment.dart';
import 'package:pulsehub/features/community/domain/post.dart';
import 'package:pulsehub/features/community/presentation/post_detail_page.dart';

import '../../../helpers/fake_auth_service.dart';
import '../../../helpers/fake_post_repository.dart';

final _post = Post(
  id: 'p1',
  authorId: 'u2',
  groupId: null,
  postType: 'text',
  content: 'hello world',
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
  authorUsername: 'alice',
  authorFullName: null,
  authorAvatarUrl: null,
  likeCount: 2,
  commentCount: 1,
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
    fakePostRepository.commentsByPost['p1'] = [
      Comment(
        id: 'c1',
        postId: 'p1',
        authorId: 'u1',
        content: 'nice post',
        createdAt: DateTime.utc(2026, 1, 1),
        authorUsername: 'me',
        authorFullName: null,
        authorAvatarUrl: null,
      ),
    ];
  });

  tearDown(() => fakeAuthService.dispose());

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          postRepositoryProvider.overrideWithValue(fakePostRepository),
        ],
        child: MaterialApp(home: PostDetailPage(post: _post, groupId: null)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the post content and existing comments', (tester) async {
    await pumpPage(tester);

    expect(find.text('hello world'), findsOneWidget);
    expect(find.text('nice post'), findsOneWidget);
  });

  testWidgets('tapping like calls setLiked and flips the icon', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();

    expect(fakePostRepository.setLikedCallCount, 1);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('submitting a comment calls addComment and clears the field',
      (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'another comment');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(fakePostRepository.addCommentCallCount, 1);
    expect(find.text('another comment'), findsNothing);
  });

  testWidgets("deleting my own comment calls deleteComment", (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(fakePostRepository.deleteCommentCallCount, 1);
  });
}
