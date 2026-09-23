import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_card.dart';

class PrivacySafetySettingsScreen extends StatefulWidget {
  const PrivacySafetySettingsScreen({super.key});

  @override
  State<PrivacySafetySettingsScreen> createState() =>
      _PrivacySafetySettingsScreenState();
}

class _PrivacySafetySettingsScreenState
    extends State<PrivacySafetySettingsScreen> {
  bool _autoEmergencyDetection = true;
  bool _vibrateWatchOnAnomaly = true;
  bool _shareWithNearbyHelpers = true;
  bool _lowBatteryAlerts = true;
  double _countdownSeconds = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Safety Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            StatusCard(
              title: 'Automatic Detection Safeguards',
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable Anomaly Detection', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Detect sudden heart-rate spikes combined with unusual motion'),
                    value: _autoEmergencyDetection,
                    activeTrackColor: AppColors.primaryPurple,
                    onChanged: (val) => setState(() => _autoEmergencyDetection = val),
                  ),
                  const Divider(height: 16),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Vibrate Watch on Anomaly', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Vibrate band strongly to prompt "Are you safe?" confirmation'),
                    value: _vibrateWatchOnAnomaly,
                    activeTrackColor: AppColors.primaryPurple,
                    onChanged: (val) => setState(() => _vibrateWatchOnAnomaly = val),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Countdown Before Dispatch',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        '${_countdownSeconds.toInt()} seconds',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple),
                      ),
                    ],
                  ),
                  Slider(
                    value: _countdownSeconds,
                    min: 10,
                    max: 45,
                    divisions: 7,
                    activeColor: AppColors.primaryPurple,
                    onChanged: (val) => setState(() => _countdownSeconds = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            StatusCard(
              title: 'Privacy & Data Protection',
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Community Helper Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Allow nearby helpers to receive approximate location during confirmed SOS'),
                    value: _shareWithNearbyHelpers,
                    activeTrackColor: AppColors.primaryPurple,
                    onChanged: (val) => setState(() => _shareWithNearbyHelpers = val),
                  ),
                  const Divider(height: 16),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Low Battery Warnings', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Notify trusted contacts if band battery drops below 15%'),
                    value: _lowBatteryAlerts,
                    activeTrackColor: AppColors.primaryPurple,
                    onChanged: (val) => setState(() => _lowBatteryAlerts = val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
