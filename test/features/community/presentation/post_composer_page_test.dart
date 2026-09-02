import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/community/application/community_providers.dart';
import 'package:pulsehub/features/community/domain/post.dart';
import 'package:pulsehub/features/community/presentation/post_composer_page.dart';

import '../../../helpers/fake_post_repository.dart';

void main() {
  late FakePostRepository fakePostRepository;

  setUp(() {
    fakePostRepository = FakePostRepository();
  });

  Future<void> pumpComposer(
    WidgetTester tester, {
    Post? existingPost,
    String? groupId,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [postRepositoryProvider.overrideWithValue(fakePostRepository)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PostComposerPage(
                        groupId: groupId,
                        existingPost: existingPost,
                      ),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows an error when submitting empty content', (tester) async {
    await pumpComposer(tester);

    await tester.tap(find.text('Post'));
    await tester.pumpAndSettle();

    expect(find.text('Write something before posting.'), findsOneWidget);
    expect(fakePostRepository.createPostCallCount, 0);
  });

  testWidgets('creates a post with the entered content and pops on success',
      (tester) async {
    await pumpComposer(tester);

    await tester.enterText(find.byType(TextField), 'Hello PulseHub');
    await tester.tap(find.text('Post'));
    await tester.pumpAndSettle();

    expect(fakePostRepository.createPostCallCount, 1);
    expect(find.byType(PostComposerPage), findsNothing);
  });

  testWidgets('pre-fills content and calls updatePost when editing',
      (tester) async {
    final existing = Post(
      id: 'p1',
      authorId: 'u1',
      groupId: null,
      postType: 'text',
      content: 'original',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
      authorUsername: 'alice',
      authorFullName: null,
      authorAvatarUrl: null,
      likeCount: 0,
      commentCount: 0,
      likedByMe: false,
    );
    await pumpComposer(tester, existingPost: existing);

    expect(find.text('original'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'edited content');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(fakePostRepository.updatePostCallCount, 1);
  });

  testWidgets('shows an error message when the create call fails',
      (tester) async {
    fakePostRepository.createPostResult =
        const Result.failure(ServerException('nope'));
    await pumpComposer(tester);

    await tester.enterText(find.byType(TextField), 'Hello PulseHub');
    await tester.tap(find.text('Post'));
    await tester.pumpAndSettle();

    expect(find.text('nope'), findsOneWidget);
    expect(find.byType(PostComposerPage), findsOneWidget);
  });
}
