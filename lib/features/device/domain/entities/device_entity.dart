import 'device_data.dart';

enum DeviceConnectionState {
  connected,
  disconnected,
  syncing,
  unknown,
}

class DeviceEntity {
  final String deviceId;
  final String ownerId;
  final DeviceConnectionState connectionState;
  final DeviceData currentData;
  final String firmwareVersion;
  final DateTime lastSeen;

  const DeviceEntity({
    required this.deviceId,
    required this.ownerId,
    required this.connectionState,
    required this.currentData,
    this.firmwareVersion = 'v1.4.2-esp32s3',
    required this.lastSeen,
  });

  bool get isConnected => connectionState == DeviceConnectionState.connected;

  DeviceEntity copyWith({
    String? deviceId,
    String? ownerId,
    DeviceConnectionState? connectionState,
    DeviceData? currentData,
    String? firmwareVersion,
    DateTime? lastSeen,
  }) {
    return DeviceEntity(
      deviceId: deviceId ?? this.deviceId,
      ownerId: ownerId ?? this.ownerId,
      connectionState: connectionState ?? this.connectionState,
      currentData: currentData ?? this.currentData,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
