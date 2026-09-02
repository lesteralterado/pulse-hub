import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/chat/presentation/widgets/user_picker_page.dart';
import 'package:pulsehub/features/profile/application/profile_providers.dart';
import 'package:pulsehub/features/profile/domain/user_profile.dart';

import '../../../../helpers/fake_profile_repository.dart';

void main() {
  late FakeProfileRepository fakeProfileRepository;

  setUp(() {
    fakeProfileRepository = FakeProfileRepository();
    fakeProfileRepository.searchResults = [
      UserProfile(
        id: 'u2',
        username: 'bob',
        fullName: 'Bob Jones',
        avatarUrl: null,
        bio: null,
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    ];
  });

  /// Pumps a host page with a button that pushes [UserPickerPage] and
  /// captures whatever it's popped with into [pickedResult].
  Future<void> pumpHost(WidgetTester tester, List<List<UserProfile>?> pickedResult) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileRepositoryProvider.overrideWithValue(fakeProfileRepository)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push<List<UserProfile>>(
                      MaterialPageRoute(builder: (_) => const UserPickerPage()),
                    );
                    pickedResult.add(result);
                  },
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

  testWidgets('searching shows matching profiles', (tester) async {
    await pumpHost(tester, []);

    await tester.enterText(find.byType(TextField), 'bob');
    await tester.pumpAndSettle();

    expect(fakeProfileRepository.searchProfilesCallCount, 1);
    expect(find.text('Bob Jones'), findsOneWidget);
    expect(find.text('@bob'), findsOneWidget);
  });

  testWidgets('selecting a profile enables Done and pops with the selection',
      (tester) async {
    final pickedResults = <List<UserProfile>?>[];
    await pumpHost(tester, pickedResults);

    expect(find.textContaining('Done'), findsNothing);

    await tester.enterText(find.byType(TextField), 'bob');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();

    expect(find.text('Done (1)'), findsOneWidget);

    await tester.tap(find.text('Done (1)'));
    await tester.pumpAndSettle();

    expect(pickedResults, hasLength(1));
    expect(pickedResults.single, hasLength(1));
    expect(pickedResults.single!.first.id, 'u2');
  });
}
