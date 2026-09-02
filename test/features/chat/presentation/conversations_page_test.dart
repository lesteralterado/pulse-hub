import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/chat/application/chat_providers.dart';
import 'package:pulsehub/features/chat/domain/conversation.dart';
import 'package:pulsehub/features/chat/presentation/conversations_page.dart';
import 'package:pulsehub/features/chat/presentation/widgets/user_picker_page.dart';
import 'package:pulsehub/features/profile/application/profile_providers.dart';

import '../../../helpers/fake_chat_repository.dart';
import '../../../helpers/fake_profile_repository.dart';

Conversation _conversation({int unreadCount = 0, bool isGroup = false, String? name}) {
  return Conversation(
    id: 'c1',
    isGroup: isGroup,
    name: name,
    createdBy: 'u2',
    createdAt: DateTime.utc(2026, 1, 1),
    lastReadAt: null,
    lastMessageContent: 'see you there',
    lastMessageAt: DateTime.utc(2026, 1, 2),
    lastMessageSenderId: 'u2',
    unreadCount: unreadCount,
    otherMemberUsername: 'bob',
    otherMemberFullName: 'Bob Jones',
    otherMemberAvatarUrl: null,
  );
}

void main() {
  late FakeChatRepository fakeChatRepository;

  setUp(() {
    fakeChatRepository = FakeChatRepository();
  });

  tearDown(() => fakeChatRepository.dispose());

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatRepositoryProvider.overrideWithValue(fakeChatRepository),
          profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
        ],
        child: const MaterialApp(home: ConversationsPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows an empty state with no conversations', (tester) async {
    await pumpPage(tester);

    expect(
      find.text('No conversations yet. Start one with the button below.'),
      findsOneWidget,
    );
  });

  testWidgets("lists conversations with the other member's name", (tester) async {
    fakeChatRepository.conversations = [_conversation()];
    await pumpPage(tester);

    expect(find.text('Bob Jones'), findsOneWidget);
    expect(find.text('see you there'), findsOneWidget);
  });

  testWidgets('shows an unread badge when there are unread messages', (tester) async {
    fakeChatRepository.conversations = [_conversation(unreadCount: 4)];
    await pumpPage(tester);

    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('the compose FAB opens the new-conversation flow', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byIcon(Icons.add_comment_outlined));
    await tester.pumpAndSettle();

    // NewConversationPage immediately pushes UserPickerPage in its
    // initState, so the stable end state to assert on is the picker.
    expect(find.byType(UserPickerPage), findsOneWidget);
  });
}
