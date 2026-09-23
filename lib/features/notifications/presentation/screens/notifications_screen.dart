import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/aegis_bottom_nav.dart';
import '../../../../core/widgets/aegis_top_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final notifications = [
      _NotificationItem(
        title: 'Emergency Resolved',
        body: 'Manual SOS incident has been resolved and marked safe by wearer.',
        time: '10 mins ago',
        icon: Icons.check_circle_rounded,
        color: AppColors.safeGreen,
        eventId: 'emg_hist_01',
      ),
      _NotificationItem(
        title: 'Emergency Alert Acknowledged',
        body: 'Trusted Contact Mother acknowledged your emergency notification.',
        time: '25 mins ago',
        icon: Icons.verified_user_rounded,
        color: AppColors.primary,
        eventId: 'emg_hist_01',
      ),
      _NotificationItem(
        title: 'Automatic Anomaly Cancelled',
        body: 'Unusual heart-rate surge was marked as safe by user within countdown.',
        time: '4 days ago',
        icon: Icons.health_and_safety_outlined,
        color: AppColors.warningAmber,
        eventId: 'emg_hist_02',
      ),
      _NotificationItem(
        title: 'Low Battery Warning (Watch)',
        body: 'Wearable battery dropped below 20%. Please connect magnetic charger.',
        time: '1 week ago',
        icon: Icons.battery_alert_rounded,
        color: AppColors.warningAmber,
      ),
    ];

    return Scaffold(
      appBar: const AegisTopBar(
        title: 'Safety Alerts',
        showBackButton: true,
      ),
      bottomNavigationBar: const AegisBottomNav(
        currentIndex: 2,
        hasUnreadAlerts: false,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: notifications.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = notifications[index];

            return Card(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.time,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                onTap: item.eventId != null
                    ? () => context.push('/emergency/details/${item.eventId}')
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color color;
  final String? eventId;

  const _NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    this.eventId,
  });
}
