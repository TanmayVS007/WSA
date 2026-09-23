import '../entities/emergency_event.dart';

abstract class EmergencyRepository {
  Stream<EmergencyEvent?> get activeEmergencyStream;
  Future<List<EmergencyEvent>> getEmergencyHistory(String userId);
  Future<EmergencyEvent> triggerEmergency({
    required String userId,
    required String deviceId,
    required EmergencyTriggerSource triggerSource,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    int? heartRateSnapshot,
    int? batterySnapshot,
  });
  Future<void> updateEmergencyStatus({
    required String eventId,
    required EmergencyStatus newStatus,
    String? reason,
  });
  Future<void> acknowledgeEmergency({
    required String eventId,
    required String contactId,
  });
  Future<void> resolveEmergency({
    required String eventId,
    String? resolutionNotes,
  });
  Future<void> cancelEmergency({
    required String eventId,
    required String reason,
  });
}
