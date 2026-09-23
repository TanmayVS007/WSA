import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/emergency_event.dart';
import '../providers/emergency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_time_formatter.dart';

class EmergencyHistoryScreen extends ConsumerWidget {
  const EmergencyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyState = ref.watch(emergencyNotifierProvider);
    final history = emergencyState.history;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency History'),
      ),
      body: SafeArea(
        child: history.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 64,
                      color: Colors.grey.withAlpha(120),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Emergency History',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'No past emergency incidents recorded.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: history.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final event = history[index];

                  final (statusColor, statusBg, statusIcon) = switch (event.status) {
                    EmergencyStatus.resolved => (
                        AppColors.safeGreen,
                        AppColors.safeGreenLight,
                        Icons.check_circle_rounded,
                      ),
                    EmergencyStatus.cancelled => (
                        AppColors.warningAmber,
                        AppColors.warningAmberLight,
                        Icons.cancel_rounded,
                      ),
                    EmergencyStatus.active || EmergencyStatus.acknowledged => (
                        AppColors.emergencyRed,
                        AppColors.emergencyRedLight,
                        Icons.emergency_rounded,
                      ),
                    _ => (
                        AppColors.unknownGrey,
                        AppColors.unknownGreyLight,
                        Icons.help_outline_rounded,
                      ),
                  };

                  final triggerLabel = switch (event.triggerSource) {
                    EmergencyTriggerSource.manualSos => 'Manual SOS',
                    EmergencyTriggerSource.automaticAnomaly => 'Automatic Detection',
                    EmergencyTriggerSource.fallDetection => 'Fall Detection',
                    EmergencyTriggerSource.appSos => 'App Triggered SOS',
                  };

                  return Card(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push('/emergency/details/${event.eventId}'),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateTimeFormatter.formatDate(event.createdAt),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: statusColor, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(statusIcon, size: 14, color: statusColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        event.status.name.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              triggerLabel,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondaryLight),
                                const SizedBox(width: 6),
                                Text(
                                  DateTimeFormatter.formatTime(event.createdAt),
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                ),
                                const SizedBox(width: 14),
                                if (event.heartRateSnapshot != null) ...[
                                  const Icon(Icons.favorite_rounded, size: 14, color: AppColors.accentRose),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${event.heartRateSnapshot} bpm',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                  ),
                                ],
                              ],
                            ),
                            if (event.resolutionNotes != null || event.cancellationReason != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDarkElevated : AppColors.unknownGreyLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  event.resolutionNotes ?? event.cancellationReason ?? '',
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
