import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';
import 'package:pulsehub/features/chat/application/chat_providers.dart';
import 'package:pulsehub/features/chat/domain/conversation.dart';
import 'package:pulsehub/features/chat/domain/conversation_member.dart';
import 'package:pulsehub/features/chat/domain/message.dart';
import 'package:pulsehub/features/chat/presentation/conversation_page.dart';

import '../../../helpers/fake_auth_service.dart';
import '../../../helpers/fake_chat_repository.dart';

final _directConversation = Conversation(
  id: 'c1',
  isGroup: false,
  name: null,
  createdBy: 'u1',
  createdAt: DateTime.utc(2026, 1, 1),
  lastReadAt: null,
  lastMessageContent: null,
  lastMessageAt: null,
  lastMessageSenderId: null,
  unreadCount: 0,
  otherMemberUsername: 'bob',
  otherMemberFullName: 'Bob Jones',
  otherMemberAvatarUrl: null,
);

final _groupConversation = Conversation(
  id: 'c2',
  isGroup: true,
  name: 'Investors',
  createdBy: 'u1',
  createdAt: DateTime.utc(2026, 1, 1),
  lastReadAt: null,
  lastMessageContent: null,
  lastMessageAt: null,
  lastMessageSenderId: null,
  unreadCount: 0,
  otherMemberUsername: null,
  otherMemberFullName: null,
  otherMemberAvatarUrl: null,
);

void main() {
  late FakeAuthService fakeAuthService;
  late FakeChatRepository fakeChatRepository;

  setUp(() {
    fakeAuthService = FakeAuthService(
      initialUser: const AppUser(id: 'u1', email: 'user@example.com', isEmailVerified: true),
    );
    fakeChatRepository = FakeChatRepository();
  });

  tearDown(() {
    fakeAuthService.dispose();
    fakeChatRepository.dispose();
  });

  Future<void> pumpPage(WidgetTester tester, Conversation conversation) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          chatRepositoryProvider.overrideWithValue(fakeChatRepository),
        ],
        child: MaterialApp(home: ConversationPage(conversation: conversation)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('marks the conversation as read on open', (tester) async {
    await pumpPage(tester, _directConversation);

    expect(fakeChatRepository.markAsReadCallCount, 1);
  });

  testWidgets('shows an empty state with no messages', (tester) async {
    await pumpPage(tester, _directConversation);

    expect(find.text('No messages yet. Say hello!'), findsOneWidget);
  });

  testWidgets('shows seeded messages and reacts to new ones sent', (tester) async {
    fakeChatRepository.seedMessages('c1', [
      Message(
        id: 'm1',
        conversationId: 'c1',
        senderId: 'u2',
        content: 'hey there',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    ]);
    await pumpPage(tester, _directConversation);

    expect(find.text('hey there'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'how are you');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(fakeChatRepository.sendMessageCallCount, 1);
    expect(find.text('how are you'), findsOneWidget);
  });

  testWidgets('long-pressing my own message offers to delete it', (tester) async {
    fakeChatRepository.seedMessages('c1', [
      Message(
        id: 'm1',
        conversationId: 'c1',
        senderId: 'u1',
        content: 'my message',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    ]);
    await pumpPage(tester, _directConversation);

    await tester.longPress(find.text('my message'));
    await tester.pumpAndSettle();

    expect(fakeChatRepository.deleteMessageCallCount, 1);
  });

  testWidgets('group chats show the sender name above other people\'s messages',
      (tester) async {
    fakeChatRepository.membersByConversation['c2'] = [
      ConversationMember(
        userId: 'u2',
        role: 'member',
        joinedAt: DateTime.utc(2026, 1, 1),
        username: 'carol',
        fullName: 'Carol Diaz',
        avatarUrl: null,
      ),
    ];
    fakeChatRepository.seedMessages('c2', [
      Message(
        id: 'm1',
        conversationId: 'c2',
        senderId: 'u2',
        content: 'group hello',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    ]);
    await pumpPage(tester, _groupConversation);

    expect(find.text('Carol Diaz'), findsOneWidget);
    expect(find.text('group hello'), findsOneWidget);
  });

  testWidgets('group chats show a members icon that opens the members sheet',
      (tester) async {
    fakeChatRepository.membersByConversation['c2'] = [
      ConversationMember(
        userId: 'u1',
        role: 'owner',
        joinedAt: DateTime.utc(2026, 1, 1),
        username: 'me',
        fullName: null,
        avatarUrl: null,
      ),
    ];
    await pumpPage(tester, _groupConversation);

    await tester.tap(find.byIcon(Icons.people_outline));
    await tester.pumpAndSettle();

    expect(find.text('Members'), findsOneWidget);
  });
}
