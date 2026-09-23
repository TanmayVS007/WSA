import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/emergency_event.dart';
import '../providers/emergency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/status_card.dart';

class EmergencyDetailsScreen extends ConsumerWidget {
  final String eventId;

  const EmergencyDetailsScreen({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyState = ref.watch(emergencyNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    EmergencyEvent? event;
    if (emergencyState.activeEvent?.eventId == eventId) {
      event = emergencyState.activeEvent;
    } else {
      try {
        event = emergencyState.history.firstWhere((e) => e.eventId == eventId);
      } catch (_) {
        event = null;
      }
    }

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Incident Details')),
        body: const Center(child: Text('Emergency incident not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Incident Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: event.isActive ? AppColors.emergencyRed : AppColors.safeGreen,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      event.isActive ? Icons.emergency_rounded : Icons.check_circle_rounded,
                      size: 48,
                      color: event.isActive ? AppColors.emergencyRed : AppColors.safeGreen,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'STATUS: ${event.status.name.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: event.isActive ? AppColors.emergencyRed : AppColors.safeGreen,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Incident ID: ${event.eventId}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              StatusCard(
                title: 'Incident Timeline & Trigger',
                child: Column(
                  children: [
                    _row('Trigger Source', event.triggerSource.name),
                    const Divider(height: 16),
                    _row('Initiated At', DateTimeFormatter.formatDateTime(event.createdAt)),
                    const Divider(height: 16),
                    _row('Last Updated', DateTimeFormatter.formatDateTime(event.updatedAt)),
                    const Divider(height: 16),
                    _row('Originating Device', event.deviceId),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              StatusCard(
                title: 'Sensor Snapshot at Trigger',
                child: Column(
                  children: [
                    _row('Heart Rate at Event', '${event.heartRateSnapshot ?? "--"} bpm', isPink: true),
                    const Divider(height: 16),
                    _row('Wearable Battery', '${event.batterySnapshot ?? "--"}%'),
                    const Divider(height: 16),
                    _row('GNSS Latitude', event.latitude?.toStringAsFixed(5) ?? 'Unavailable'),
                    const Divider(height: 16),
                    _row('GNSS Longitude', event.longitude?.toStringAsFixed(5) ?? 'Unavailable'),
                    const Divider(height: 16),
                    _row('GPS Accuracy', '~${event.accuracyMeters?.toStringAsFixed(1) ?? "--"} meters'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (event.acknowledgedBy.isNotEmpty) ...[
                StatusCard(
                  title: 'Acknowledged By Guardians',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: event.acknowledgedBy
                        .map(
                          (contact) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_user_rounded, size: 16, color: AppColors.safeGreen),
                                const SizedBox(width: 8),
                                Text(contact, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => context.push('/map'),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Open Incident Map', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isPink = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isPink ? AppColors.accentRose : null,
          ),
        ),
      ],
    );
  }
}
