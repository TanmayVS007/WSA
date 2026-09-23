import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../device/presentation/widgets/mock_hardware_control_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionHeader('SAFETY & HARDWARE'),
            _buildSettingTile(
              context,
              icon: Icons.shield_outlined,
              title: 'Privacy & Safety Settings',
              subtitle: 'Emergency triggers, countdown duration, nearby helper sharing',
              onTap: () => context.push('/settings/privacy-safety'),
            ),
            _buildSettingTile(
              context,
              icon: Icons.watch_outlined,
              title: 'Paired Watch Hardware',
              subtitle: 'ESP32-S3 band, firmware v1.4.2, SIM7600 modem',
              onTap: () => context.push('/watch-status'),
            ),
            _buildSettingTile(
              context,
              icon: Icons.developer_mode_rounded,
              title: 'Hardware Simulation Tools',
              subtitle: 'Simulate sensors, vitals, battery, and emergency events',
              onTap: () => MockHardwareControlSheet.show(context),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('GUARDIANS & COMMUNITY'),
            _buildSettingTile(
              context,
              icon: Icons.people_outline,
              title: 'Trusted Contacts Network',
              subtitle: 'Manage family and emergency responders',
              onTap: () => context.push('/contacts'),
            ),
            _buildSettingTile(
              context,
              icon: Icons.volunteer_activism_outlined,
              title: 'Nearby Helper Network',
              subtitle: 'Opt-in/out and radius preferences',
              onTap: () => context.push('/nearby-help'),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('APP & SYSTEM'),
            _buildSettingTile(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notification Settings',
              subtitle: 'High-priority critical alerts, vibration intensity',
              onTap: () => context.push('/notifications'),
            ),
            _buildSettingTile(
              context,
              icon: Icons.help_outline_rounded,
              title: 'Help & Emergency FAQ',
              subtitle: 'Learn about false alarm prevention and SOS workflows',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Women Safety Band Help & Documentation')),
                );
              },
            ),
            _buildSettingTile(
              context,
              icon: Icons.info_outline,
              title: 'About Women Safety Band',
              subtitle: 'Version 1.0.0 (Build 2026.09)',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryPurpleLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryPurple, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
        ),
        trailing: const Icon(Icons.chevron_right, size: 18),
      ),
    );
  }
}
