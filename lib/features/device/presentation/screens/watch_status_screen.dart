import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/device_data.dart';
import '../../domain/entities/device_entity.dart';
import '../providers/device_provider.dart';
import '../widgets/mock_hardware_control_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/status_card.dart';

class WatchStatusScreen extends ConsumerWidget {
  const WatchStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceState = ref.watch(deviceNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (statusLabel, statusColor, statusBgColor, statusIcon) =
        switch (deviceState.connectionState) {
      DeviceConnectionState.connected => (
          'CONNECTED',
          AppColors.safeGreen,
          AppColors.safeGreenLight,
          Icons.bluetooth_connected_rounded,
        ),
      DeviceConnectionState.disconnected => (
          'DISCONNECTED',
          AppColors.emergencyRed,
          AppColors.emergencyRedLight,
          Icons.bluetooth_disabled_rounded,
        ),
      DeviceConnectionState.syncing => (
          'SYNCING',
          AppColors.warningAmber,
          AppColors.warningAmberLight,
          Icons.sync_rounded,
        ),
      DeviceConnectionState.unknown => (
          'UNKNOWN',
          AppColors.unknownGrey,
          AppColors.unknownGreyLight,
          Icons.help_outline_rounded,
        ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.developer_mode_rounded),
            tooltip: 'Hardware Simulator',
            onPressed: () => MockHardwareControlSheet.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Connection Status Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor, width: 1.5),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deviceState.isConnected
                          ? 'Real-time sensor telemetry streaming actively'
                          : 'Hardware offline. Reconnect or verify Bluetooth / 4G coverage.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Hardware Details Card
              const Text(
                'HARDWARE SPECIFICATIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 10),
              StatusCard(
                title: 'Device Information',
                child: Column(
                  children: [
                    _buildDetailRow('Device ID', deviceState.deviceId),
                    const Divider(height: 16),
                    _buildDetailRow('Firmware Version', deviceState.firmwareVersion),
                    const Divider(height: 16),
                    _buildDetailRow('Controller', 'ESP32-S3 Dual-Core Xtensa'),
                    const Divider(height: 16),
                    _buildDetailRow('Cellular Modem', 'SIM7600G-H Multi-Band LTE'),
                    const Divider(height: 16),
                    _buildDetailRow('Last Synchronized', DateTimeFormatter.formatDateTime(deviceState.lastSeen)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Sensor & Telemetry Metrics
              const Text(
                'LIVE TELEMETRY METRICS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 10),
              StatusCard(
                title: 'Sensors & Signal Status',
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Battery Percentage',
                      '${deviceState.currentData.batteryPercentage}%',
                      trailingColor: deviceState.currentData.isLowBattery
                          ? AppColors.warningAmber
                          : AppColors.safeGreen,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      'Network State',
                      deviceState.currentData.networkStatus == NetworkStatus.cellular4G
                          ? '4G Cellular (SIM7600)'
                          : 'Bluetooth Low Energy',
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      'GNSS / GPS State',
                      deviceState.currentData.gpsStatus == GpsStatus.available
                          ? 'Available (Locked • ~4.2m)'
                          : 'Searching / Offline',
                      trailingColor: deviceState.currentData.gpsStatus == GpsStatus.available
                          ? AppColors.safeGreen
                          : AppColors.unknownGrey,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      'Heart Rate Sensor',
                      '${deviceState.currentData.heartRate ?? "--"} bpm (Optical PPG)',
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      'Motion / IMU State',
                      deviceState.currentData.motionState.name.toUpperCase(),
                    ),
                    const Divider(height: 16),
                    _buildDetailRow('Cloud Synchronization', 'Active (Firestore Realtime)'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Actions
              if (deviceState.isConnected) ...[
                AppButton(
                  text: 'Disconnect Watch',
                  variant: AppButtonVariant.outline,
                  onPressed: () => ref.read(deviceNotifierProvider.notifier).disconnect(),
                ),
              ] else ...[
                AppButton(
                  text: 'Reconnect Watch',
                  isLoading: deviceState.isConnecting,
                  onPressed: () => ref.read(deviceNotifierProvider.notifier).reconnect(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? trailingColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: trailingColor,
            ),
          ),
        ),
      ],
    );
  }
}
