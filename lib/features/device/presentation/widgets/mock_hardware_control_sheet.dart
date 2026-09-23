import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/device_provider.dart';
import '../../../emergency/presentation/providers/emergency_provider.dart';
import '../../../../core/theme/app_colors.dart';

class MockHardwareControlSheet extends ConsumerWidget {
  const MockHardwareControlSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const MockHardwareControlSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockService = ref.watch(deviceCommunicationServiceProvider);
    final deviceState = ref.watch(deviceNotifierProvider);
    final emergencyState = ref.watch(emergencyNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(90),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurpleLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.developer_mode_rounded,
                      color: AppColors.primaryPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hardware Simulator Controls',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Simulate ESP32 wearable sensor & alert states',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'CONNECTION & BATTERY',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.bluetooth_connected, size: 16, color: AppColors.safeGreen),
                    label: const Text('Connect Watch'),
                    onPressed: () => mockService.simulateWatchConnected(),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.bluetooth_disabled, size: 16, color: AppColors.emergencyRed),
                    label: const Text('Disconnect Watch'),
                    onPressed: () => mockService.simulateWatchDisconnected(),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.battery_alert, size: 16, color: AppColors.warningAmber),
                    label: const Text('Low Battery (9%)'),
                    onPressed: () => mockService.simulateLowBattery(),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.gps_fixed, size: 16, color: AppColors.safeGreen),
                    label: const Text('GPS Available'),
                    onPressed: () => mockService.simulateGpsAvailable(),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.gps_off, size: 16, color: AppColors.unknownGrey),
                    label: const Text('GPS Unavailable'),
                    onPressed: () => mockService.simulateGpsUnavailable(),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text(
                'VITALS & MOTION ANOMALY',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.favorite, size: 16, color: AppColors.safeGreen),
                    label: const Text('Normal HR (72 bpm)'),
                    onPressed: () => mockService.simulateNormalHeartRate(),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.speed, size: 16, color: AppColors.warningAmber),
                    label: const Text('HR Spike (145 bpm)'),
                    onPressed: () => mockService.simulateHighHeartRate(),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.directions_run, size: 16, color: AppColors.warningAmber),
                    label: const Text('Abnormal Motion'),
                    onPressed: () => mockService.simulateAbnormalMotion(),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text(
                'EMERGENCY TRIGGERS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.emergencyRed),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warningAmber,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        mockService.simulateAutomaticEmergency();
                      },
                      icon: const Icon(Icons.notifications_active_rounded, size: 18),
                      label: const Text('Auto Anomaly', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emergencyRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        mockService.simulateManualSos();
                      },
                      icon: const Icon(Icons.emergency_rounded, size: 18),
                      label: const Text('Hardware SOS', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),

              if (emergencyState.hasActiveEmergency) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.safeGreen,
                      side: const BorderSide(color: AppColors.safeGreen, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      ref.read(emergencyNotifierProvider.notifier).resolveEmergency();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Resolve Active Emergency', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDarkElevated : AppColors.unknownGreyLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Live telemetry: ${deviceState.currentData.batteryPercentage}% battery | HR: ${deviceState.currentData.heartRate ?? "--"} bpm | GPS: ${deviceState.currentData.gpsStatus.name}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
