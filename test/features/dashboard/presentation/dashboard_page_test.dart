import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/dashboard/presentation/dashboard_page.dart';

void main() {
  testWidgets('shows the three visually separated sections', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardPage()));

    expect(find.widgetWithText(AppBar, 'Dashboard'), findsOneWidget);
    expect(find.text('BOT Chain'), findsOneWidget);
    expect(find.text('CaryPact'), findsOneWidget);
    expect(find.text('PulseHub'), findsOneWidget);
  });
}
