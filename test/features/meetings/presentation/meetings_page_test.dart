import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/auth/application/auth_providers.dart';
import 'package:pulsehub/features/auth/domain/app_user.dart';
import 'package:pulsehub/features/meetings/application/meeting_providers.dart';
import 'package:pulsehub/features/meetings/domain/meeting.dart';
import 'package:pulsehub/features/meetings/presentation/create_meeting_page.dart';
import 'package:pulsehub/features/meetings/presentation/meeting_detail_page.dart';
import 'package:pulsehub/features/meetings/presentation/meetings_page.dart';

import '../../../helpers/fake_auth_service.dart';
import '../../../helpers/fake_meeting_repository.dart';

Meeting _meeting({String status = 'scheduled'}) {
  return Meeting(
    id: 'm1',
    hostId: 'u2',
    title: 'Weekly sync',
    description: null,
    scheduledStart: DateTime.now().add(const Duration(days: 1)),
    scheduledEnd: DateTime.now().add(const Duration(days: 1, hours: 1)),
    status: status,
    locked: false,
    createdAt: DateTime.utc(2026, 1, 1),
    hostUsername: 'bob',
    hostFullName: 'Bob Jones',
    participantCount: 3,
    myRsvpStatus: null,
  );
}

void main() {
  late FakeAuthService fakeAuthService;
  late FakeMeetingRepository fakeMeetingRepository;

  setUp(() {
    fakeAuthService = FakeAuthService(
      initialUser: const AppUser(id: 'u1', email: 'user@example.com', isEmailVerified: true),
    );
    fakeMeetingRepository = FakeMeetingRepository();
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
        child: const MaterialApp(home: MeetingsPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows an empty state with no meetings', (tester) async {
    await pumpPage(tester);
    expect(find.text('No meetings scheduled yet.'), findsOneWidget);
  });

  testWidgets('lists meetings with host and status', (tester) async {
    fakeMeetingRepository.meetings = [_meeting()];
    await pumpPage(tester);

    expect(find.text('Weekly sync'), findsOneWidget);
    expect(find.text('Hosted by Bob Jones'), findsOneWidget);
    expect(find.text('Scheduled'), findsOneWidget);
  });

  testWidgets('tapping the FAB opens the create-meeting page', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(CreateMeetingPage), findsOneWidget);
  });

  testWidgets('tapping a meeting opens its detail page', (tester) async {
    fakeMeetingRepository.meetings = [_meeting()];
    await pumpPage(tester);

    await tester.tap(find.text('Weekly sync'));
    await tester.pumpAndSettle();

    expect(find.byType(MeetingDetailPage), findsOneWidget);
  });
}
