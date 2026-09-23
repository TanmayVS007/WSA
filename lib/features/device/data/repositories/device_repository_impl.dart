import '../datasources/device_communication_service.dart';
import '../../domain/entities/device_data.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/device_repository.dart';
import '../../../emergency/domain/entities/emergency_event.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceCommunicationService _communicationService;

  DeviceRepositoryImpl(this._communicationService);

  @override
  Stream<DeviceData> get telemetryStream =>
      _communicationService.deviceDataStream;

  @override
  Stream<DeviceConnectionState> get connectionStateStream =>
      _communicationService.connectionStateStream;

  @override
  Stream<EmergencyEvent> get emergencyStream =>
      _communicationService.emergencyStream;

  @override
  Future<DeviceEntity> getDeviceStatus() =>
      _communicationService.getDeviceStatus();

  @override
  Future<void> connect({String? deviceId}) =>
      _communicationService.connect(deviceId: deviceId);

  @override
  Future<void> disconnect() => _communicationService.disconnect();

  @override
  Future<void> sendCommand(String command, {Map<String, dynamic>? params}) =>
      _communicationService.sendCommand(command, params: params);
}
