import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/meetings/application/meeting_providers.dart';
import 'package:pulsehub/features/meetings/domain/meeting.dart';
import 'package:pulsehub/features/meetings/domain/meeting_participant.dart';
import 'package:pulsehub/features/meetings/presentation/meeting_call_page.dart';

import '../../../helpers/fake_livekit_service.dart';
import '../../../helpers/fake_meeting_repository.dart';

final _meeting = Meeting(
  id: 'm1',
  hostId: 'u1',
  title: 'Weekly sync',
  description: null,
  scheduledStart: DateTime.now(),
  scheduledEnd: DateTime.now().add(const Duration(hours: 1)),
  status: 'live',
  locked: false,
  createdAt: DateTime.utc(2026, 1, 1),
  hostUsername: 'alice',
  hostFullName: null,
  participantCount: 1,
  myRsvpStatus: 'going',
);

void main() {
  late FakeMeetingRepository fakeMeetingRepository;
  late FakeLiveKitService fakeLiveKitService;

  setUp(() {
    fakeMeetingRepository = FakeMeetingRepository();
    fakeMeetingRepository.participantsByMeeting['m1'] = [
      const MeetingParticipant(
        userId: 'u1',
        role: 'host',
        rsvpStatus: 'going',
        joinedAt: null,
        username: 'alice',
        fullName: null,
        avatarUrl: null,
      ),
    ];
    fakeLiveKitService = FakeLiveKitService();
  });

  tearDown(() => fakeMeetingRepository.dispose());

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          meetingRepositoryProvider.overrideWithValue(fakeMeetingRepository),
          liveKitServiceProvider.overrideWithValue(fakeLiveKitService),
        ],
        child: MaterialApp(home: MeetingCallPage(meeting: _meeting)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows participant placeholders from real meeting data',
      (tester) async {
    await pumpPage(tester);
    expect(find.text('alice'), findsOneWidget);
  });

  testWidgets("shows a not-set-up-yet banner since LiveKit isn't configured",
      (tester) async {
    await pumpPage(tester);
    expect(find.textContaining("isn't set up yet"), findsWidgets);
  });

  testWidgets('tapping mute shows a not-configured message rather than doing nothing',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byIcon(Icons.mic));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.mic_off), findsOneWidget);
    expect(
      find.text("Video calling isn't set up yet — this control has no LiveKit connection to act on."),
      findsOneWidget,
    );
  });

  testWidgets('tapping the end-call button pops the screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          meetingRepositoryProvider.overrideWithValue(fakeMeetingRepository),
          liveKitServiceProvider.overrideWithValue(fakeLiveKitService),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MeetingCallPage(meeting: _meeting)),
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

    await tester.tap(find.byIcon(Icons.call_end));
    await tester.pumpAndSettle();

    expect(find.byType(MeetingCallPage), findsNothing);
  });
}
