import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/learning/presentation/learn_page.dart';

void main() {
  testWidgets('shows the coming-soon message', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LearnPage()));

    expect(find.widgetWithText(AppBar, 'Learn'), findsOneWidget);
    expect(find.textContaining('coming soon'), findsOneWidget);
  });
}
