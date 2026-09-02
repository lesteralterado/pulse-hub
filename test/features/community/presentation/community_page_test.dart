import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/community/presentation/community_page.dart';

void main() {
  testWidgets('shows the coming-soon message', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CommunityPage()));

    expect(find.widgetWithText(AppBar, 'Community'), findsOneWidget);
    expect(find.textContaining('coming soon'), findsOneWidget);
  });
}
