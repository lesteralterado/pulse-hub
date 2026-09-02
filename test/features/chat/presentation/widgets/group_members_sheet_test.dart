import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';
import 'package:pulsehub/features/chat/application/chat_providers.dart';
import 'package:pulsehub/features/chat/domain/conversation_member.dart';
import 'package:pulsehub/features/chat/presentation/widgets/group_members_sheet.dart';
import 'package:pulsehub/features/profile/application/profile_providers.dart';

import '../../../../helpers/fake_auth_service.dart';
import '../../../../helpers/fake_chat_repository.dart';
import '../../../../helpers/fake_profile_repository.dart';

void main() {
  late FakeAuthService fakeAuthService;
  late FakeChatRepository fakeChatRepository;

  setUp(() {
    fakeAuthService = FakeAuthService(
      initialUser: const AppUser(id: 'u1', email: 'user@example.com', isEmailVerified: true),
    );
    fakeChatRepository = FakeChatRepository();
    fakeChatRepository.membersByConversation['c1'] = [
      ConversationMember(
        userId: 'u1',
        role: 'owner',
        joinedAt: DateTime.utc(2026, 1, 1),
        username: 'me',
        fullName: null,
        avatarUrl: null,
      ),
      ConversationMember(
        userId: 'u2',
        role: 'member',
        joinedAt: DateTime.utc(2026, 1, 1),
        username: 'bob',
        fullName: 'Bob Jones',
        avatarUrl: null,
      ),
    ];
  });

  tearDown(() {
    fakeAuthService.dispose();
    fakeChatRepository.dispose();
  });

  Future<void> pumpSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          chatRepositoryProvider.overrideWithValue(fakeChatRepository),
          profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showGroupMembersSheet(context, 'c1'),
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

  testWidgets('lists members with their roles', (tester) async {
    await pumpSheet(tester);

    expect(find.text('Bob Jones'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(find.text('Member'), findsOneWidget);
  });

  testWidgets('the owner can remove another member', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    await tester.pumpAndSettle();

    expect(fakeChatRepository.removeMemberCallCount, 1);
  });

  testWidgets('the owner cannot remove themselves', (tester) async {
    await pumpSheet(tester);

    // Only one remove button should exist (for the non-self member).
    expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
  });
}
