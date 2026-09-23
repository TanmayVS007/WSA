import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class AegisBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool hasUnreadAlerts;

  const AegisBottomNav({
    super.key,
    required this.currentIndex,
    this.hasUnreadAlerts = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;


    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceContainerLowest.withAlpha(240),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.cardBorderDark : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1C30).withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                icon: Icons.shield_rounded,
                outlineIcon: Icons.shield_outlined,
                label: 'Home',
                path: '/dashboard',
              ),
              _buildNavItem(
                context: context,
                index: 1,
                icon: Icons.explore_rounded,
                outlineIcon: Icons.explore_outlined,
                label: 'Map',
                path: '/map',
              ),
              _buildNavItem(
                context: context,
                index: 2,
                icon: Icons.notifications_rounded,
                outlineIcon: Icons.notifications_outlined,
                label: 'Alerts',
                path: '/notifications',
                hasBadge: hasUnreadAlerts,
              ),
              _buildNavItem(
                context: context,
                index: 3,
                icon: Icons.group_rounded,
                outlineIcon: Icons.group_outlined,
                label: 'Contacts',
                path: '/contacts',
              ),
              _buildNavItem(
                context: context,
                index: 4,
                icon: Icons.person_rounded,
                outlineIcon: Icons.person_outline_rounded,
                label: 'Profile',
                path: '/profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData outlineIcon,
    required String label,
    required String path,
    bool hasBadge = false,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (currentIndex != index) {
            context.go(path);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? icon : outlineIcon,
                  color: color,
                  size: 24,
                ),
                if (hasBadge)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.emergencyRed,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
