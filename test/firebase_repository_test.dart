import 'package:flutter_test/flutter_test.dart';
import 'package:women_safety_band/features/authentication/domain/entities/user_entity.dart';
import 'package:women_safety_band/features/emergency/domain/entities/emergency_event.dart';

void main() {
  group('Firebase Domain & Entity Mapping Tests', () {
    test('UserEntity maintains role and device id correctly for wearable owner', () {
      final user = UserEntity(
        userId: 'usr_firebase_123',
        name: 'Jane Doe',
        email: 'jane@example.com',
        phone: '+91 99999 88888',
        role: UserRole.wearableOwner,
        deviceId: 'wsb_esp32_78a1',
        createdAt: DateTime(2026, 9, 10),
      );

      expect(user.userId, 'usr_firebase_123');
      expect(user.role, UserRole.wearableOwner);
      expect(user.deviceId, 'wsb_esp32_78a1');
    });

    test('EmergencyEvent correctly reflects active state for detected and active events', () {
      final activeEvent = EmergencyEvent(
        eventId: 'emg_001',
        userId: 'usr_firebase_123',
        deviceId: 'wsb_esp32_78a1',
        triggerSource: EmergencyTriggerSource.manualSos,
        status: EmergencyStatus.active,
        latitude: 18.52043,
        longitude: 73.85674,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(activeEvent.isActive, true);
      expect(activeEvent.isConfirmationPending, false);

      final detectedEvent = activeEvent.copyWith(
        status: EmergencyStatus.detected,
        triggerSource: EmergencyTriggerSource.automaticAnomaly,
      );

      expect(detectedEvent.isActive, false);
      expect(detectedEvent.isConfirmationPending, true);
    });
  });
}
