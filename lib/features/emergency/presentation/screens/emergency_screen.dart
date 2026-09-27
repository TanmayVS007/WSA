import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/emergency_event.dart';
import '../providers/emergency_provider.dart';
import '../../../device/presentation/providers/device_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/app_logo.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  void _showPinResolutionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PinResolutionModal(
        onSuccess: () {
          ref
              .read(emergencyNotifierProvider.notifier)
              .resolveEmergency(
                notes: 'Verified safe via Master Safety PIN authentication',
              );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.tertiary,
              content: Text(
                'Safety PIN validated. Alert resolved and emergency channels updated.',
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emergencyState = ref.watch(emergencyNotifierProvider);
    final deviceState = ref.watch(deviceNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeEvent = emergencyState.activeEvent;
    final isEmergencyActive = emergencyState.hasActiveEmergency;
    final batteryLevel = deviceState.currentData.batteryPercentage;

    return Scaffold(
      backgroundColor: isEmergencyActive
          ? (isDark ? const Color(0xFF160909) : const Color(0xFFFFF7F7))
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEmergencyActive
                    ? AppColors.emergencyRed
                    : AppColors.primary,
              ),
              child: isEmergencyActive
                  ? const Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : const AppLogo.circle(size: 24, fit: BoxFit.contain),
            ),
            const SizedBox(width: 10),
            Text(
              isEmergencyActive ? 'SOS ACTIVE' : 'Emergency Central',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isEmergencyActive) ...[
                // 1. Emergency Active Pulsing Banner
                _PulsingEmergencyBanner(event: activeEvent),
                const SizedBox(height: 14),

                // 2. Live Broadcasting Card
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.emergencyRed,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'LIVE BROADCASTING',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.emergencyRed,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDarkElevated
                                  : AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.gps_fixed_rounded,
                                  size: 14,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '±4m accuracy',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Location Representation Box
                      Container(
                        width: double.infinity,
                        height: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(220),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.radar_rounded,
                                      size: 12,
                                      color: AppColors.tertiary,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '5s Refresh GNSS',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.emergencyRed,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'MG Road, Camp',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          'Pune, Maharashtra 411001',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Telemetry status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.battery_charging_full_rounded,
                                size: 16,
                                color: AppColors.tertiary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Aegis Band: $batteryLevel% Battery',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Row(
                            children: [
                              Icon(
                                Icons.cloud_sync_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Firebase Stream Active',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Response Status Tracker (Automated Protocol)
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
                          const Text(
                            'Response Status Tracker',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'AUTOMATED PROTOCOL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      _buildTimelineItem(
                        icon: Icons.check_rounded,
                        iconColor: AppColors.onTertiaryFixed,
                        iconBg: AppColors.tertiaryFixed,
                        title: 'Emergency Alert Broadcasted',
                        time: DateTimeFormatter.formatTime(
                          activeEvent?.createdAt ?? DateTime.now(),
                        ),
                        subtitle: 'Cloud beacons initiated across secure safety relays.',
                        isComplete: true,
                        isLast: false,
                      ),
                      _buildTimelineItem(
                        icon: Icons.check_rounded,
                        iconColor: AppColors.onTertiaryFixed,
                        iconBg: AppColors.tertiaryFixed,
                        title: 'Trusted Contacts Notified (3/3)',
                        time: 'Delivered',
                        subtitle: 'Delivered via high-priority SMS, automated call & Push.',
                        isComplete: true,
                        isLast: false,
                      ),
                      _buildTimelineItem(
                        icon: Icons.hourglass_top_rounded,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.secondaryContainer,
                        title: 'Nearby Helpers Alerted',
                        time: 'In Progress',
                        timeColor: AppColors.primary,
                        subtitle: '4 verified community responders within 500m radius.',
                        isComplete: false,
                        isLast: false,
                      ),
                      _buildTimelineItem(
                        icon: Icons.check_rounded,
                        iconColor: AppColors.onTertiaryFixed,
                        iconBg: AppColors.tertiaryFixed,
                        title: 'Police Control Room 112',
                        time: 'Ready',
                        timeColor: AppColors.tertiary,
                        subtitle: 'Encrypted telemetry & live dispatch URL generated.',
                        isComplete: true,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // 4. Oversized Direct Action Buttons
                _buildActionButton(
                  context: context,
                  title: 'Call Primary Contact',
                  subtitle: 'Mother (+91 •••• 4321)',
                  icon: Icons.call_rounded,
                  iconBg: AppColors.primaryFixed,
                  iconColor: AppColors.primary,
                  backgroundColor: AppColors.primary,
                  onTap: () {
                    ref
                        .read(emergencyNotifierProvider.notifier)
                        .callPrimaryContact('+919876543211');
                  },
                ),
                const SizedBox(height: 10),

                _buildActionButton(
                  context: context,
                  title: 'Dial Emergency 112',
                  subtitle: 'Direct National Emergency Response',
                  icon: Icons.local_police_rounded,
                  iconBg: AppColors.errorContainer,
                  iconColor: AppColors.onErrorContainer,
                  backgroundColor: AppColors.emergencyRed,
                  onTap: () {
                    ref.read(emergencyNotifierProvider.notifier).dial112();
                  },
                ),
                const SizedBox(height: 10),

                _buildActionButton(
                  context: context,
                  title: 'Dispatch Emergency SMS',
                  subtitle: 'Send live coordinates to all trusted guardians',
                  icon: Icons.sms_rounded,
                  iconBg: AppColors.tertiaryFixed,
                  iconColor: AppColors.onTertiaryFixed,
                  backgroundColor: AppColors.tertiary,
                  onTap: () {
                    ref
                        .read(emergencyNotifierProvider.notifier)
                        .sendEmergencySms(
                          phoneNumbers: [
                            '+919876543211',
                            '+919876543212',
                            '+919876543213',
                          ],
                        );
                  },
                ),
                const SizedBox(height: 10),

                // View Map Tracker Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.surfaceDarkElevated
                          : AppColors.surfaceContainerHigh,
                      foregroundColor: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.onSurface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => context.push('/map'),
                    icon: const Icon(
                      Icons.navigation_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    label: const Text(
                      'View Full Live Map Tracker',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Safety Resolution Protocol
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDarkElevated
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.lock_clock_rounded,
                            size: 16,
                            color: AppColors.onSurfaceVariant,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'SAFETY RESOLUTION PROTOCOL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'To cancel this alert or mark yourself safe, 4-digit Master Safety PIN authentication is required to prevent coerced deactivations.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.surfaceDark
                                : AppColors.surfaceContainerLowest,
                            foregroundColor: AppColors.tertiary,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => _showPinResolutionSheet(context),
                          icon: const Icon(
                            Icons.verified_user_rounded,
                            color: AppColors.tertiary,
                            size: 18,
                          ),
                          label: const Text(
                            'Resolve & Mark Safe',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Safe / Standby Mode
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
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
                        color: const Color(0xFF0B1C30).withAlpha(8),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryContainer.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.tertiary,
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'NO ACTIVE EMERGENCY',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.tertiary,
                          letterSpacing: 0.8,
                        ),
                        softWrap: true,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Your Aegis Band safety network is armed. Wearable telemetry, fall detection, and biometric anomaly scans are active in standby mode.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emergencyRed,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            ref
                                .read(emergencyNotifierProvider.notifier)
                                .triggerManualSos();
                          },
                          icon: const Icon(Icons.emergency_rounded, size: 22),
                          label: const Text(
                            'ACTIVATE SOS BEACON NOW',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String time,
    Color? timeColor,
    required String subtitle,
    required bool isComplete,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
              child: Icon(icon, color: iconColor, size: 14),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: isComplete
                    ? AppColors.tertiaryFixed
                    : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: timeColor ?? AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withAlpha(90),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBg,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingEmergencyBanner extends StatefulWidget {
  final EmergencyEvent? event;
  const _PulsingEmergencyBanner({this.event});

  @override
  State<_PulsingEmergencyBanner> createState() =>
      _PulsingEmergencyBannerState();
}

class _PulsingEmergencyBannerState extends State<_PulsingEmergencyBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.emergencyRed,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.emergencyRed.withAlpha(
                  (80 + (_controller.value * 90)).toInt(),
                ),
                blurRadius: 18,
                spreadRadius: 2 * _controller.value,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.emergency_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'EMERGENCY ACTIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(45),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'SOS TRANSMITTED',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                        // TextStyle(
                        //   color: Colors.white,
                        //   fontSize: 10,
                        //   fontWeight: FontWeight.w800,
                        //   letterSpacing: 0.6,
                        // ),
                        softWrap: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Manual SOS Triggered via Aegis Band',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today, ${DateTimeFormatter.formatTime(widget.event?.createdAt ?? DateTime.now())}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  Text(
                    'ID: #${widget.event?.eventId.substring(0, 8).toUpperCase() ?? "EMG-8821"}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PinResolutionModal extends StatefulWidget {
  final VoidCallback onSuccess;
  const _PinResolutionModal({required this.onSuccess});

  @override
  State<_PinResolutionModal> createState() => _PinResolutionModalState();
}

class _PinResolutionModalState extends State<_PinResolutionModal> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _verifyPin() {
    final pin = _controllers.map((c) => c.text).join();
    if (pin.length == 4) {
      Navigator.of(context).pop();
      widget.onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a complete 4-digit PIN.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      color: AppColors.tertiary,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Enter Safety PIN',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Confirm you are unharmed. Entering your duress PIN will silently maintain emergency services dispatch.',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 54,
                  height: 60,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    obscureText: true,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: isDark
                          ? AppColors.surfaceDarkElevated
                          : AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty && index < 3) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (val.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      if (_controllers.every((c) => c.text.isNotEmpty)) {
                        _verifyPin();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tertiary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _verifyPin,
                child: const Text(
                  'Confirm Resolution',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Keep SOS Active',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
