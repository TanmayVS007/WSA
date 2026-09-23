import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/mock_device_communication_service.dart';
import '../../domain/entities/device_data.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/device_repository.dart';
import '../../data/repositories/device_repository_impl.dart';

// Underlying hardware communication service (Mock simulator default)
final deviceCommunicationServiceProvider =
    Provider<MockDeviceCommunicationService>((ref) {
  final service = MockDeviceCommunicationService();
  ref.onDispose(() => service.dispose());
  return service;
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  final commService = ref.watch(deviceCommunicationServiceProvider);
  return DeviceRepositoryImpl(commService);
});

// Device state
class DeviceState {
  final DeviceConnectionState connectionState;
  final DeviceData currentData;
  final String deviceId;
  final String firmwareVersion;
  final DateTime lastSeen;
  final bool isConnecting;
  final String? error;

  const DeviceState({
    required this.connectionState,
    required this.currentData,
    required this.deviceId,
    required this.firmwareVersion,
    required this.lastSeen,
    this.isConnecting = false,
    this.error,
  });

  bool get isConnected => connectionState == DeviceConnectionState.connected;

  DeviceState copyWith({
    DeviceConnectionState? connectionState,
    DeviceData? currentData,
    String? deviceId,
    String? firmwareVersion,
    DateTime? lastSeen,
    bool? isConnecting,
    String? error,
  }) {
    return DeviceState(
      connectionState: connectionState ?? this.connectionState,
      currentData: currentData ?? this.currentData,
      deviceId: deviceId ?? this.deviceId,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      lastSeen: lastSeen ?? this.lastSeen,
      isConnecting: isConnecting ?? this.isConnecting,
      error: error,
    );
  }
}

class DeviceNotifier extends Notifier<DeviceState> {
  StreamSubscription<DeviceData>? _telemetrySub;
  StreamSubscription<DeviceConnectionState>? _connectionSub;

  DeviceRepository get _repository => ref.read(deviceRepositoryProvider);

  @override
  DeviceState build() {
    ref.onDispose(() {
      _telemetrySub?.cancel();
      _connectionSub?.cancel();
    });

    _initStreams();

    return DeviceState(
      connectionState: DeviceConnectionState.connected,
      currentData: DeviceData(
        heartRate: 74,
        motionState: MotionState.normalWalking,
        batteryPercentage: 82,
        latitude: 18.52043,
        longitude: 73.85674,
        gpsAccuracy: 4.2,
        gpsStatus: GpsStatus.available,
        networkStatus: NetworkStatus.cellular4G,
        timestamp: DateTime.now(),
      ),
      deviceId: 'wsb_esp32_78a1',
      firmwareVersion: 'v1.4.2-esp32s3',
      lastSeen: DateTime.now(),
    );
  }

  void _initStreams() {
    _telemetrySub = _repository.telemetryStream.listen((data) {
      state = state.copyWith(
        currentData: data,
        lastSeen: data.timestamp,
      );
    });

    _connectionSub = _repository.connectionStateStream.listen((connState) {
      state = state.copyWith(connectionState: connState);
    });
  }

  Future<void> reconnect() async {
    state = state.copyWith(isConnecting: true);
    await _repository.connect(deviceId: state.deviceId);
    state = state.copyWith(isConnecting: false);
  }

  Future<void> disconnect() async {
    await _repository.disconnect();
  }
}

final deviceNotifierProvider =
    NotifierProvider<DeviceNotifier, DeviceState>(DeviceNotifier.new);
