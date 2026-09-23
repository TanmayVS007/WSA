import '../entities/device_data.dart';
import '../entities/device_entity.dart';
import '../../../emergency/domain/entities/emergency_event.dart';

abstract class DeviceRepository {
  Stream<DeviceData> get telemetryStream;
  Stream<DeviceConnectionState> get connectionStateStream;
  Stream<EmergencyEvent> get emergencyStream;
  Future<DeviceEntity> getDeviceStatus();
  Future<void> connect({String? deviceId});
  Future<void> disconnect();
  Future<void> sendCommand(String command, {Map<String, dynamic>? params});
}
