import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../device/domain/entities/device_data.dart';
import '../../../device/presentation/providers/device_provider.dart';
import '../../../device/presentation/widgets/mock_hardware_control_sheet.dart';
import '../../../emergency/presentation/providers/emergency_provider.dart';
import '../../../emergency/presentation/widgets/anomaly_warning_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/aegis_bottom_nav.dart';
import '../../../../core/widgets/aegis_top_bar.dart';
import '../../../../core/widgets/emergency_button.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  bool _anomalyDialogShown = false;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final deviceState = ref.watch(deviceNotifierProvider);
    final emergencyState = ref.watch(emergencyNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Reactively show anomaly confirmation dialog when anomaly is detected
    ref.listen<EmergencyState>(emergencyNotifierProvider, (previous, next) {
      if (next.isConfirmationPending && !_anomalyDialogShown) {
        _anomalyDialogShown = true;
        AnomalyWarningDialog.show(context);
      } else if (!next.isConfirmationPending) {
        _anomalyDialogShown = false;
      }
    });

    final userName = authState.user?.name ?? 'Ananya';
    final nowFormatted = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Scaffold(
      appBar: const AegisTopBar(title: 'Dashboard'),
      bottomNavigationBar: const AegisBottomNav(currentIndex: 0),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.developer_mode_rounded, size: 20),
        label: const Text(
          'Simulator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => MockHardwareControlSheet.show(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Emergency Warning Banner (if emergency is active)
            if (emergencyState.hasActiveEmergency) ...[
              GestureDetector(
                onTap: () => context.push('/emergency'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.emergencyRed,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emergencyRed.withAlpha(90),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.emergency_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🚨 ACTIVE EMERGENCY BROADCASTING',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Live GPS & telemetry broadcasting. Tap to view status.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],

            // 1. Greeting Header with Date & Verified Shield Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nowFormatted.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        '${_getGreeting()}, $userName',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? AppColors.surfaceDarkElevated
                        : AppColors.surfaceContainerHigh,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Primary Safety Status Card (Active Shield Enabled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.cardBorderDark
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B1C30).withAlpha(8),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryContainer.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: AppColors.tertiary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'SAFE',
                                style: TextStyle(
                                  color: AppColors.onTertiaryFixedVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Active Shield Enabled',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Your wearable is connected and monitoring normally.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDarkElevated
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.security_rounded,
                      color: AppColors.tertiary,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Watch Status Widget (4 Telemetry Sensor Pills)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.cardBorderDark
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B1C30).withAlpha(8),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: deviceState.isConnected
                                  ? AppColors.tertiary
                                  : AppColors.warningAmber,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            deviceState.isConnected
                                ? 'WSB-001 Connected'
                                : 'WSB-001 Searching',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.push('/watch-status'),
                        child: const Text(
                          'Live Telemetry',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSensorPill(
                          context: context,
                          icon: Icons.battery_charging_full_rounded,
                          iconColor: AppColors.tertiary,
                          label: 'Battery',
                          value:
                              '${deviceState.currentData.batteryPercentage}%',
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSensorPill(
                          context: context,
                          icon: Icons.signal_cellular_alt_rounded,
                          iconColor: AppColors.primary,
                          label: 'Cellular',
                          value:
                              deviceState.currentData.networkStatus ==
                                  NetworkStatus.cellular4G
                              ? '4G LTE'
                              : 'BLE Sync',
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSensorPill(
                          context: context,
                          icon: Icons.near_me_rounded,
                          iconColor: AppColors.tertiary,
                          label: 'GPS Status',
                          value:
                              deviceState.currentData.gpsStatus ==
                                  GpsStatus.available
                              ? 'High Accuracy'
                              : 'Searching',
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSensorPill(
                          context: context,
                          icon: Icons.sync_rounded,
                          iconColor: AppColors.secondarySlate,
                          label: 'Last Sync',
                          value: '2 mins ago',
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Quick Action Shortcuts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                const Text(
                  'Real-time Feed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                _buildActionRow(
                  context: context,
                  icon: Icons.map_rounded,
                  iconBg: AppColors.secondaryContainer,
                  iconColor: AppColors.primary,
                  title: 'Live Locator',
                  subtitle: 'Pune, MH • Balewadi High St',
                  isDark: isDark,
                  onTap: () => context.push('/map'),
                ),
                const SizedBox(height: 8),
                _buildActionRow(
                  context: context,
                  icon: Icons.monitor_heart_rounded,
                  iconBg: AppColors.surfaceContainerHigh,
                  iconColor: AppColors.primary,
                  title: 'Band Health & Sensors',
                  subtitle:
                      '${deviceState.currentData.heartRate ?? 78} BPM • Normal Motion',
                  isDark: isDark,
                  onTap: () => context.push('/watch-status'),
                ),
                const SizedBox(height: 8),
                _buildActionRow(
                  context: context,
                  icon: Icons.diversity_1_rounded,
                  iconBg: AppColors.tertiaryContainer.withAlpha(25),
                  iconColor: AppColors.tertiary,
                  title: 'Safety Network',
                  subtitle: '4 Nearby Helpers active',
                  isDark: isDark,
                  onTap: () => context.push('/nearby-help'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 5. Trusted Contacts Quick Bar
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/contacts'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.cardBorderDark
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B1C30).withAlpha(8),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Overlapping avatars
                    SizedBox(
                      width: 60,
                      height: 32,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: _buildAvatarCircle('M', AppColors.primary),
                          ),
                          Positioned(
                            left: 16,
                            child: _buildAvatarCircle(
                              'D',
                              AppColors.secondarySlate,
                            ),
                          ),
                          Positioned(
                            left: 32,
                            child: _buildAvatarCircle('P', AppColors.tertiary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '3 Contacts Active',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Mom, Dad, Priya',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryContainer.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: AppColors.tertiary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'ALERTS ON',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onTertiaryFixedVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.outline,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 6. Primary SOS Trigger Panel
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? AppColors.cardBorderDark
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B1C30).withAlpha(10),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'EMERGENCY BROADCAST',
                    style: TextStyle(
                      color: AppColors.emergencyRed,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aegis Emergency Beacon',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 18),

                  // 3-second hold circular SOS button
                  EmergencyButton(
                    onTrigger: () {
                      ref
                          .read(emergencyNotifierProvider.notifier)
                          .triggerManualSos();
                      context.push('/emergency');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80), // Padding for simulator FAB
          ],
        ),
      ),
    );
  }

  Widget _buildSensorPill({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDarkElevated
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceContainerLowest,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.cardBorderDark : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.outline,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCircle(String label, Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
