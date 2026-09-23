import '../../domain/entities/device_data.dart';
import '../../domain/entities/device_entity.dart';
import '../../../emergency/domain/entities/emergency_event.dart';

/// Abstract contract for wearable device communication.
/// Implementations can be Mock (Simulator), BLE (GATT), Cellular (MQTT/SIM7600), or Cloud.
abstract class DeviceCommunicationService {
  /// Establish communication with the wearable
  Future<void> connect({String? deviceId});

  /// Terminate connection
  Future<void> disconnect();

  /// Real-time stream of sensor telemetry (heart rate, motion, battery, GPS)
  Stream<DeviceData> get deviceDataStream;

  /// Stream of connection state updates
  Stream<DeviceConnectionState> get connectionStateStream;

  /// Stream of emergency trigger events originated directly by the watch hardware
  Stream<EmergencyEvent> get emergencyStream;

  /// Fetch an immediate status snapshot
  Future<DeviceEntity> getDeviceStatus();

  /// Send commands to the wearable (vibrate motor, cancel alarm on watch display, ping)
  Future<void> sendCommand(String command, {Map<String, dynamic>? params});
}
