enum EmergencyStatus {
  safe,
  detected,
  confirmationCountdown,
  active,
  acknowledged,
  resolved,
  cancelled,
}

enum EmergencyTriggerSource {
  manualSos,
  automaticAnomaly,
  fallDetection,
  appSos,
}

enum LocationFreshness {
  live,
  recent,
  stale,
  unavailable,
}

class EmergencyEvent {
  final String eventId;
  final String userId;
  final String deviceId;
  final EmergencyTriggerSource triggerSource;
  final EmergencyStatus status;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final LocationFreshness locationFreshness;
  final int? heartRateSnapshot;
  final int? batterySnapshot;
  final List<String> acknowledgedBy;
  final String? cancellationReason;
  final String? resolutionNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmergencyEvent({
    required this.eventId,
    required this.userId,
    required this.deviceId,
    required this.triggerSource,
    required this.status,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.locationFreshness = LocationFreshness.live,
    this.heartRateSnapshot,
    this.batterySnapshot,
    this.acknowledgedBy = const [],
    this.cancellationReason,
    this.resolutionNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive =>
      status == EmergencyStatus.active || status == EmergencyStatus.acknowledged;

  bool get isConfirmationPending =>
      status == EmergencyStatus.detected ||
      status == EmergencyStatus.confirmationCountdown;

  EmergencyEvent copyWith({
    String? eventId,
    String? userId,
    String? deviceId,
    EmergencyTriggerSource? triggerSource,
    EmergencyStatus? status,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    LocationFreshness? locationFreshness,
    int? heartRateSnapshot,
    int? batterySnapshot,
    List<String>? acknowledgedBy,
    String? cancellationReason,
    String? resolutionNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmergencyEvent(
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      triggerSource: triggerSource ?? this.triggerSource,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      locationFreshness: locationFreshness ?? this.locationFreshness,
      heartRateSnapshot: heartRateSnapshot ?? this.heartRateSnapshot,
      batterySnapshot: batterySnapshot ?? this.batterySnapshot,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
