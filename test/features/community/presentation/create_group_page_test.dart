import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/errors/app_exception.dart';
import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/community/application/community_providers.dart';
import 'package:pulsehub/features/community/presentation/create_group_page.dart';

import '../../../helpers/fake_group_repository.dart';

void main() {
  late FakeGroupRepository fakeGroupRepository;

  setUp(() {
    fakeGroupRepository = FakeGroupRepository();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [groupRepositoryProvider.overrideWithValue(fakeGroupRepository)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateGroupPage()),
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

  testWidgets('rejects an empty name without calling the service',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);
    expect(fakeGroupRepository.createGroupCallCount, 0);
  });

  testWidgets('creates a group and pops on success', (tester) async {
    await pumpPage(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Group name'),
      'Beginner Blockchain',
    );
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(fakeGroupRepository.createGroupCallCount, 1);
    expect(find.byType(CreateGroupPage), findsNothing);
  });

  testWidgets('shows an error message when creation fails', (tester) async {
    fakeGroupRepository.createGroupResult =
        const Result.failure(ServerException('nope'));
    await pumpPage(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Group name'),
      'Beginner Blockchain',
    );
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('nope'), findsOneWidget);
  });
}
