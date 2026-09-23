import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:women_safety_band/app/app.dart';

import 'package:women_safety_band/features/authentication/presentation/providers/auth_provider.dart';
import 'package:women_safety_band/features/emergency/presentation/providers/emergency_provider.dart';

void main() {
  testWidgets('Women Safety Band App renders splash screen correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isMockAuthModeProvider.overrideWithValue(true),
          isMockEmergencyModeProvider.overrideWithValue(true),
        ],
        child: const WomenSafetyApp(),
      ),
    );

    // Verify splash branding elements
    expect(find.textContaining('WOMEN'), findsOneWidget);
    expect(find.textContaining('Always Connected'), findsOneWidget);

    // Advance timer past splash duration so all timers complete cleanly
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
  });
}
