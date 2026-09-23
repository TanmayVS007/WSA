import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../domain/entities/emergency_event.dart';
import '../../domain/repositories/emergency_repository.dart';

class MockEmergencyRepository implements EmergencyRepository {
  final _uuid = const Uuid();
  EmergencyEvent? _activeEmergency;
  final _activeEmergencyController =
      StreamController<EmergencyEvent?>.broadcast();

  final List<EmergencyEvent> _history = [
    EmergencyEvent(
      eventId: 'emg_hist_01',
      userId: 'usr_owner_demo',
      deviceId: 'wsb_esp32_78a1',
      triggerSource: EmergencyTriggerSource.manualSos,
      status: EmergencyStatus.resolved,
      latitude: 18.52043,
      longitude: 73.85674,
      accuracyMeters: 4.0,
      heartRateSnapshot: 124,
      batterySnapshot: 84,
      acknowledgedBy: ['Mother (+91 98765 43211)'],
      resolutionNotes: 'Safe at home with family.',
      createdAt: DateTime(2026, 9, 9, 22, 10),
      updatedAt: DateTime(2026, 9, 9, 22, 25),
    ),
    EmergencyEvent(
      eventId: 'emg_hist_02',
      userId: 'usr_owner_demo',
      deviceId: 'wsb_esp32_78a1',
      triggerSource: EmergencyTriggerSource.automaticAnomaly,
      status: EmergencyStatus.cancelled,
      latitude: 18.52150,
      longitude: 73.85720,
      accuracyMeters: 5.2,
      heartRateSnapshot: 138,
      batterySnapshot: 79,
      cancellationReason: 'False alarm during brisk jogging exercise.',
      createdAt: DateTime(2026, 9, 5, 18, 45),
      updatedAt: DateTime(2026, 9, 5, 18, 45, 18),
    ),
    EmergencyEvent(
      eventId: 'emg_hist_03',
      userId: 'usr_owner_demo',
      deviceId: 'wsb_esp32_78a1',
      triggerSource: EmergencyTriggerSource.manualSos,
      status: EmergencyStatus.resolved,
      latitude: 18.51890,
      longitude: 73.85430,
      accuracyMeters: 3.8,
      heartRateSnapshot: 130,
      batterySnapshot: 91,
      acknowledgedBy: ['Father (+91 98765 43212)', 'Local Police Patrol'],
      resolutionNotes: 'Assistance arrived, safely escorted.',
      createdAt: DateTime(2026, 8, 28, 21, 30),
      updatedAt: DateTime(2026, 8, 28, 22, 00),
    ),
  ];

  @override
  Stream<EmergencyEvent?> get activeEmergencyStream =>
      _activeEmergencyController.stream;

  @override
  Future<List<EmergencyEvent>> getEmergencyHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_history);
  }

  @override
  Future<EmergencyEvent> triggerEmergency({
    required String userId,
    required String deviceId,
    required EmergencyTriggerSource triggerSource,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    int? heartRateSnapshot,
    int? batterySnapshot,
  }) async {
    final newEvent = EmergencyEvent(
      eventId: 'emg_${_uuid.v4().substring(0, 8)}',
      userId: userId,
      deviceId: deviceId,
      triggerSource: triggerSource,
      status: triggerSource == EmergencyTriggerSource.automaticAnomaly
          ? EmergencyStatus.detected
          : EmergencyStatus.active,
      latitude: latitude ?? 18.52043,
      longitude: longitude ?? 73.85674,
      accuracyMeters: accuracyMeters ?? 4.2,
      locationFreshness: LocationFreshness.live,
      heartRateSnapshot: heartRateSnapshot ?? 136,
      batterySnapshot: batterySnapshot ?? 82,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _activeEmergency = newEvent;
    _activeEmergencyController.add(_activeEmergency);
    return newEvent;
  }

  @override
  Future<void> updateEmergencyStatus({
    required String eventId,
    required EmergencyStatus newStatus,
    String? reason,
  }) async {
    if (_activeEmergency != null && _activeEmergency!.eventId == eventId) {
      _activeEmergency = _activeEmergency!.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      _activeEmergencyController.add(_activeEmergency);
    }
  }

  @override
  Future<void> acknowledgeEmergency({
    required String eventId,
    required String contactId,
  }) async {
    if (_activeEmergency != null && _activeEmergency!.eventId == eventId) {
      final updatedList = List<String>.from(_activeEmergency!.acknowledgedBy)
        ..add(contactId);
      _activeEmergency = _activeEmergency!.copyWith(
        status: EmergencyStatus.acknowledged,
        acknowledgedBy: updatedList,
        updatedAt: DateTime.now(),
      );
      _activeEmergencyController.add(_activeEmergency);
    }
  }

  @override
  Future<void> cancelEmergency({
    required String eventId,
    required String reason,
  }) async {
    if (_activeEmergency != null && _activeEmergency!.eventId == eventId) {
      final cancelledEvent = _activeEmergency!.copyWith(
        status: EmergencyStatus.cancelled,
        cancellationReason: reason,
        updatedAt: DateTime.now(),
      );
      _history.insert(0, cancelledEvent);
      _activeEmergency = null;
      _activeEmergencyController.add(null);
    }
  }

  @override
  Future<void> resolveEmergency({
    required String eventId,
    String? resolutionNotes,
  }) async {
    if (_activeEmergency != null && _activeEmergency!.eventId == eventId) {
      final resolvedEvent = _activeEmergency!.copyWith(
        status: EmergencyStatus.resolved,
        resolutionNotes: resolutionNotes ?? 'Marked safe by user',
        updatedAt: DateTime.now(),
      );
      _history.insert(0, resolvedEvent);
      _activeEmergency = null;
      _activeEmergencyController.add(null);
    }
  }
}
