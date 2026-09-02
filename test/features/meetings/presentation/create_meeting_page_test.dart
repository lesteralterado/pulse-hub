import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/meetings/application/meeting_providers.dart';
import 'package:pulsehub/features/meetings/presentation/create_meeting_page.dart';

import '../../../helpers/fake_meeting_repository.dart';

void main() {
  late FakeMeetingRepository fakeMeetingRepository;

  setUp(() {
    fakeMeetingRepository = FakeMeetingRepository();
  });

  tearDown(() => fakeMeetingRepository.dispose());

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [meetingRepositoryProvider.overrideWithValue(fakeMeetingRepository)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateMeetingPage()),
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

  testWidgets('rejects an empty title without calling the service', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Title is required'), findsOneWidget);
    expect(fakeMeetingRepository.createMeetingCallCount, 0);
  });

  testWidgets('creates a meeting with the entered title and pops on success',
      (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'Weekly sync');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(fakeMeetingRepository.createMeetingCallCount, 1);
    expect(find.byType(CreateMeetingPage), findsNothing);
  });

  testWidgets('shows an error message when creation fails', (tester) async {
    fakeMeetingRepository.createMeetingResult =
        const Result.failure(ServerException('nope'));
    await pumpPage(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'Weekly sync');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('nope'), findsOneWidget);
  });
}
