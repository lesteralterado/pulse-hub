import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';
import 'package:pulsehub/features/meetings/application/meeting_providers.dart';
import 'package:pulsehub/features/meetings/domain/meeting_message.dart';
import 'package:pulsehub/features/meetings/domain/meeting_participant.dart';
import 'package:pulsehub/features/meetings/presentation/meeting_chat_page.dart';

import '../../../helpers/fake_auth_service.dart';
import '../../../helpers/fake_meeting_repository.dart';

void main() {
  late FakeAuthService fakeAuthService;
  late FakeMeetingRepository fakeMeetingRepository;

  setUp(() {
    fakeAuthService = FakeAuthService(
      initialUser: const AppUser(id: 'u1', email: 'user@example.com', isEmailVerified: true),
    );
    fakeMeetingRepository = FakeMeetingRepository();
    fakeMeetingRepository.participantsByMeeting['m1'] = [
      const MeetingParticipant(
        userId: 'u1',
        role: 'host',
        rsvpStatus: 'going',
        joinedAt: null,
        username: 'me',
        fullName: null,
        avatarUrl: null,
      ),
    ];
  });

  tearDown(() {
    fakeAuthService.dispose();
    fakeMeetingRepository.dispose();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          meetingRepositoryProvider.overrideWithValue(fakeMeetingRepository),
        ],
        child: const MaterialApp(home: MeetingChatPage(meetingId: 'm1')),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows an empty state with no messages', (tester) async {
    await pumpPage(tester);
    expect(find.text('No messages yet.'), findsOneWidget);
  });

  testWidgets('shows seeded messages', (tester) async {
    fakeMeetingRepository.seedMessages('m1', [
      MeetingMessage(
        id: 'msg1',
        meetingId: 'm1',
        senderId: 'u1',
        content: 'hello team',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    ]);
    await pumpPage(tester);

    expect(find.text('hello team'), findsOneWidget);
  });

  testWidgets('sending a message calls sendMeetingMessage and clears the field',
      (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'let\'s begin');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(fakeMeetingRepository.sendMeetingMessageCallCount, 1);
    // The sent message correctly reappears as a bubble via the fake's
    // realtime stream — what this test actually checks is that the
    // input field itself was cleared after sending.
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, isEmpty);
  });

  testWidgets('deleting my own message calls deleteMeetingMessage', (tester) async {
    fakeMeetingRepository.seedMessages('m1', [
      MeetingMessage(
        id: 'msg1',
        meetingId: 'm1',
        senderId: 'u1',
        content: 'hello team',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    ]);
    await pumpPage(tester);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(fakeMeetingRepository.deleteMeetingMessageCallCount, 1);
  });
}
