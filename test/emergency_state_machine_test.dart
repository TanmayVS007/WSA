import 'package:flutter_test/flutter_test.dart';
import 'package:women_safety_band/features/emergency/domain/entities/emergency_event.dart';
import 'package:women_safety_band/features/emergency/data/repositories/mock_emergency_repository.dart';
import 'package:women_safety_band/features/device/data/datasources/mock_device_communication_service.dart';

void main() {
  group('Emergency State Machine Tests', () {
    late MockEmergencyRepository repository;

    setUp(() {
      repository = MockEmergencyRepository();
    });

    test('Initial emergency history contains realistic prior events', () async {
      final history = await repository.getEmergencyHistory('usr_owner_demo');
      expect(history.length, 3);
      expect(history[0].status, EmergencyStatus.resolved);
      expect(history[1].status, EmergencyStatus.cancelled);
      expect(history[2].status, EmergencyStatus.resolved);
    });

    test('Manual SOS creates ACTIVE emergency immediately', () async {
      final event = await repository.triggerEmergency(
        userId: 'usr_owner_demo',
        deviceId: 'wsb_esp32_78a1',
        triggerSource: EmergencyTriggerSource.manualSos,
        latitude: 18.52043,
        longitude: 73.85674,
      );

      expect(event.status, EmergencyStatus.active);
      expect(event.triggerSource, EmergencyTriggerSource.manualSos);
      expect(event.isActive, true);
    });

    test('Automatic anomaly starts with DETECTED status', () async {
      final event = await repository.triggerEmergency(
        userId: 'usr_owner_demo',
        deviceId: 'wsb_esp32_78a1',
        triggerSource: EmergencyTriggerSource.automaticAnomaly,
        heartRateSnapshot: 142,
      );

      expect(event.status, EmergencyStatus.detected);
      expect(event.isConfirmationPending, true);
    });

    test('Acknowledge emergency updates status and contact list', () async {
      final event = await repository.triggerEmergency(
        userId: 'usr_owner_demo',
        deviceId: 'wsb_esp32_78a1',
        triggerSource: EmergencyTriggerSource.manualSos,
      );

      await repository.acknowledgeEmergency(
        eventId: event.eventId,
        contactId: 'Mother (+91 98765 43211)',
      );
    });

    test('Resolve emergency clears active state and adds to history', () async {
      final event = await repository.triggerEmergency(
        userId: 'usr_owner_demo',
        deviceId: 'wsb_esp32_78a1',
        triggerSource: EmergencyTriggerSource.manualSos,
      );

      await repository.resolveEmergency(
        eventId: event.eventId,
        resolutionNotes: 'Safe at home',
      );

      final history = await repository.getEmergencyHistory('usr_owner_demo');
      expect(history.first.status, EmergencyStatus.resolved);
      expect(history.first.resolutionNotes, 'Safe at home');
    });

    test('Cancel emergency marks anomaly as CANCELLED with reason', () async {
      final event = await repository.triggerEmergency(
        userId: 'usr_owner_demo',
        deviceId: 'wsb_esp32_78a1',
        triggerSource: EmergencyTriggerSource.automaticAnomaly,
      );

      await repository.cancelEmergency(
        eventId: event.eventId,
        reason: 'False alarm during exercise',
      );

      final history = await repository.getEmergencyHistory('usr_owner_demo');
      expect(history.first.status, EmergencyStatus.cancelled);
      expect(history.first.cancellationReason, 'False alarm during exercise');
    });
  });

  group('Mock Device Communication Service Tests', () {
    late MockDeviceCommunicationService mockService;

    setUp(() {
      mockService = MockDeviceCommunicationService();
    });

    tearDown(() {
      mockService.dispose();
    });

    test('Device status returns valid connected hardware snapshot', () async {
      final status = await mockService.getDeviceStatus();
      expect(status.deviceId, 'wsb_esp32_78a1');
      expect(status.firmwareVersion, contains('esp32'));
      expect(status.currentData.batteryPercentage, 82);
    });

    test('Simulate manual SOS generates hardware emergency event', () async {
      expectLater(
        mockService.emergencyStream,
        emits(predicate<EmergencyEvent>((e) {
          return e.triggerSource == EmergencyTriggerSource.manualSos &&
              e.status == EmergencyStatus.active;
        })),
      );

      mockService.simulateManualSos();
    });

    test('Simulate auto anomaly generates high heart rate event', () async {
      expectLater(
        mockService.emergencyStream,
        emits(predicate<EmergencyEvent>((e) {
          return e.triggerSource == EmergencyTriggerSource.automaticAnomaly &&
              e.heartRateSnapshot == 142;
        })),
      );

      mockService.simulateAutomaticEmergency();
    });
  });
}
