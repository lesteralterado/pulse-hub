import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';
import 'package:pulsehub/features/meetings/application/meeting_providers.dart';
import 'package:pulsehub/features/meetings/domain/meeting.dart';
import 'package:pulsehub/features/meetings/domain/meeting_participant.dart';
import 'package:pulsehub/features/meetings/presentation/meeting_call_page.dart';
import 'package:pulsehub/features/meetings/presentation/meeting_chat_page.dart';
import 'package:pulsehub/features/meetings/presentation/meeting_detail_page.dart';

import '../../../helpers/fake_auth_service.dart';
import '../../../helpers/fake_livekit_service.dart';
import '../../../helpers/fake_meeting_repository.dart';

Meeting _meeting({required String hostId, String status = 'scheduled'}) {
  return Meeting(
    id: 'm1',
    hostId: hostId,
    title: 'Weekly sync',
    description: 'Team catch-up',
    scheduledStart: DateTime.now().add(const Duration(days: 1)),
    scheduledEnd: DateTime.now().add(const Duration(days: 1, hours: 1)),
    status: status,
    locked: false,
    createdAt: DateTime.utc(2026, 1, 1),
    hostUsername: 'bob',
    hostFullName: 'Bob Jones',
    participantCount: 1,
    myRsvpStatus: null,
  );
}

void main() {
  late FakeAuthService fakeAuthService;
  late FakeMeetingRepository fakeMeetingRepository;
  late FakeLiveKitService fakeLiveKitService;

  setUp(() {
    fakeAuthService = FakeAuthService(
      initialUser: const AppUser(id: 'u1', email: 'user@example.com', isEmailVerified: true),
    );
    fakeMeetingRepository = FakeMeetingRepository();
    fakeLiveKitService = FakeLiveKitService();
  });

  tearDown(() {
    fakeAuthService.dispose();
    fakeMeetingRepository.dispose();
  });

  Future<void> pumpPage(WidgetTester tester, Meeting meeting) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          meetingRepositoryProvider.overrideWithValue(fakeMeetingRepository),
          liveKitServiceProvider.overrideWithValue(fakeLiveKitService),
        ],
        child: MaterialApp(home: MeetingDetailPage(meeting: meeting)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a non-host can RSVP, which calls the repository', (tester) async {
    await pumpPage(tester, _meeting(hostId: 'u2'));

    await tester.tap(find.text('RSVP'));
    await tester.pumpAndSettle();

    expect(fakeMeetingRepository.rsvpCallCount, 1);
    expect(find.text('Cancel RSVP'), findsOneWidget);
  });

  testWidgets('the host sees host controls instead of an RSVP button',
      (tester) async {
    await pumpPage(tester, _meeting(hostId: 'u1'));

    expect(find.text('Host controls'), findsOneWidget);
    expect(find.text('Start meeting'), findsOneWidget);
    expect(find.text('RSVP'), findsNothing);
  });

  testWidgets('starting the meeting shows Join call and End meeting',
      (tester) async {
    await pumpPage(tester, _meeting(hostId: 'u1'));

    await tester.tap(find.text('Start meeting'));
    await tester.pumpAndSettle();

    expect(fakeMeetingRepository.startMeetingCallCount, 1);
    expect(find.text('Join call'), findsOneWidget);
    expect(find.text('End meeting'), findsOneWidget);
  });

  testWidgets('tapping Join call records the join and opens the call screen',
      (tester) async {
    await pumpPage(tester, _meeting(hostId: 'u1', status: 'live'));

    await tester.tap(find.text('Join call'));
    await tester.pumpAndSettle();

    expect(fakeMeetingRepository.recordJoinCallCount, 1);
    expect(find.byType(MeetingCallPage), findsOneWidget);
  });

  testWidgets('the host can remove another participant', (tester) async {
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
      const MeetingParticipant(
        userId: 'u2',
        role: 'participant',
        rsvpStatus: 'going',
        joinedAt: null,
        username: 'carol',
        fullName: 'Carol Diaz',
        avatarUrl: null,
      ),
    ];
    await pumpPage(tester, _meeting(hostId: 'u1'));

    expect(find.text('Carol Diaz'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    await tester.pumpAndSettle();

    expect(fakeMeetingRepository.removeParticipantCallCount, 1);
  });

  testWidgets('the chat icon opens the meeting chat page', (tester) async {
    await pumpPage(tester, _meeting(hostId: 'u2'));

    await tester.tap(find.byIcon(Icons.chat_bubble_outline));
    await tester.pumpAndSettle();

    expect(find.byType(MeetingChatPage), findsOneWidget);
  });
}
