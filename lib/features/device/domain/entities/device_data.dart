enum MotionState {
  stationary,
  normalWalking,
  running,
  rapidAcceleration,
  fallDetected,
  unknown,
}

enum NetworkStatus {
  bleConnected,
  cellular4G,
  noNetwork,
  unknown,
}

enum GpsStatus {
  available,
  searching,
  unavailable,
}

/// Raw/processed sensor snapshot received from wearable
class DeviceData {
  final int? heartRate;
  final MotionState motionState;
  final int batteryPercentage;
  final double? latitude;
  final double? longitude;
  final double? gpsAccuracy;
  final GpsStatus gpsStatus;
  final NetworkStatus networkStatus;
  final DateTime timestamp;

  const DeviceData({
    this.heartRate,
    this.motionState = MotionState.normalWalking,
    required this.batteryPercentage,
    this.latitude,
    this.longitude,
    this.gpsAccuracy,
    this.gpsStatus = GpsStatus.available,
    this.networkStatus = NetworkStatus.cellular4G,
    required this.timestamp,
  });

  bool get isLowBattery => batteryPercentage <= 20;
  bool get isCriticalBattery => batteryPercentage <= 10;
  bool get isAbnormalHeartRate =>
      heartRate != null && (heartRate! > 130 || heartRate! < 45);

  DeviceData copyWith({
    int? heartRate,
    MotionState? motionState,
    int? batteryPercentage,
    double? latitude,
    double? longitude,
    double? gpsAccuracy,
    GpsStatus? gpsStatus,
    NetworkStatus? networkStatus,
    DateTime? timestamp,
  }) {
    return DeviceData(
      heartRate: heartRate ?? this.heartRate,
      motionState: motionState ?? this.motionState,
      batteryPercentage: batteryPercentage ?? this.batteryPercentage,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      gpsStatus: gpsStatus ?? this.gpsStatus,
      networkStatus: networkStatus ?? this.networkStatus,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
