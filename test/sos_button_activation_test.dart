import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:women_safety_band/core/widgets/emergency_button.dart';
import 'package:women_safety_band/features/emergency/domain/entities/emergency_event.dart';
import 'package:women_safety_band/features/emergency/presentation/providers/emergency_provider.dart';
import 'package:women_safety_band/features/emergency/presentation/widgets/sos_activation_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SOS Button Activation & Flow Tests', () {
    testWidgets('EmergencyButton renders properly with hold instructions',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyButton(
              onTrigger: () {},
            ),
          ),
        ),
      );

      expect(find.text('HOLD'), findsOneWidget);
      expect(find.text('FOR SOS'), findsOneWidget);
      expect(find.text('3-Second Press & Hold'), findsOneWidget);
    });

    testWidgets('Tapping EmergencyButton opens SosActivationDialog',
        (tester) async {
      bool triggered = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EmergencyButton(
                onTrigger: () {
                  triggered = true;
                },
              ),
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.byType(EmergencyButton));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify dialog is shown
      expect(find.byType(SosActivationDialog), findsOneWidget);
      expect(find.text('🚨 ACTIVATING SOS BEACON'), findsOneWidget);
      expect(find.text('ACTIVATE SOS NOW'), findsOneWidget);
      expect(find.text('CANCEL (I\'M SAFE)'), findsOneWidget);

      // Cancel it
      await tester.tap(find.text('CANCEL (I\'M SAFE)'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SosActivationDialog), findsNothing);
      expect(triggered, false);
    });

    testWidgets('Tapping ACTIVATE SOS NOW in SosActivationDialog triggers emergency',
        (tester) async {
      bool activated = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    SosActivationDialog.show(
                      context,
                      onActivated: () {
                        activated = true;
                      },
                    );
                  },
                  child: const Text('Open SOS'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open SOS'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SosActivationDialog), findsOneWidget);

      // Tap ACTIVATE SOS NOW
      await tester.tap(find.text('ACTIVATE SOS NOW'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(activated, true);
    });

    test('EmergencyNotifier triggerManualSos sets active emergency state',
        () async {
      final container = ProviderContainer(
        overrides: [
          isMockEmergencyModeProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(emergencyNotifierProvider.notifier);
      expect(container.read(emergencyNotifierProvider).hasActiveEmergency, false);

      await notifier.triggerManualSos();

      final state = container.read(emergencyNotifierProvider);
      expect(state.hasActiveEmergency, true);
      expect(state.activeEvent, isNotNull);
      expect(state.activeEvent!.status, EmergencyStatus.active);
      expect(state.activeEvent!.triggerSource, EmergencyTriggerSource.manualSos);
      expect(state.activeEvent!.latitude, isNotNull);
      expect(state.activeEvent!.longitude, isNotNull);
    });

    test('EmergencyNotifier dispatch actions execute cleanly', () async {
      final container = ProviderContainer(
        overrides: [
          isMockEmergencyModeProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(emergencyNotifierProvider.notifier);
      await notifier.triggerManualSos();

      // Verify dispatch methods don't throw
      expect(() => notifier.dial112(), returnsNormally);
      expect(() => notifier.callPrimaryContact('+919876543211'), returnsNormally);
      expect(
        () => notifier.sendEmergencySms(
          phoneNumbers: ['+919876543211', '+919876543212'],
        ),
        returnsNormally,
      );
    });
  });
}
