import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/config/startup_info.dart';
import 'package:pulsehub/main.dart';

void main() {
  testWidgets('PulseHubApp boots and shows the foundation status page',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          startupInfoProvider.overrideWithValue(
            const StartupInfo(environment: 'test', supabaseConfigured: true),
          ),
        ],
        child: const PulseHubApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PulseHub'), findsOneWidget);
    expect(find.text('Foundation ready'), findsOneWidget);
    expect(find.text('Environment: '), findsOneWidget);
    expect(find.text('test'), findsOneWidget);
    expect(find.text('Supabase: '), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
  });
}
