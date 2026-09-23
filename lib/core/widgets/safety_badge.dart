import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum SafetyStatusLevel {
  safe,
  warning,
  emergency,
  unknown,
}

/// Dual-coded safety badge using both explicit icons and accessible color coding.
class SafetyBadge extends StatelessWidget {
  final SafetyStatusLevel status;
  final bool isLarge;

  const SafetyBadge({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final (label, icon, fgColor, bgColor) = switch (status) {
      SafetyStatusLevel.safe => (
          'SAFE',
          Icons.check_circle_rounded,
          AppColors.safeGreen,
          AppColors.safeGreenLight,
        ),
      SafetyStatusLevel.warning => (
          'WARNING',
          Icons.warning_amber_rounded,
          AppColors.warningAmber,
          AppColors.warningAmberLight,
        ),
      SafetyStatusLevel.emergency => (
          'EMERGENCY ACTIVE',
          Icons.emergency_rounded,
          AppColors.emergencyRed,
          AppColors.emergencyRedLight,
        ),
      SafetyStatusLevel.unknown => (
          'UNKNOWN',
          Icons.help_outline_rounded,
          AppColors.unknownGrey,
          AppColors.unknownGreyLight,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 20 : 12,
        vertical: isLarge ? 12 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isLarge ? 28 : 20),
        border: Border.all(color: fgColor, width: isLarge ? 2 : 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isLarge ? 24 : 16,
            color: fgColor,
          ),
          SizedBox(width: isLarge ? 10 : 6),
          Text(
            label,
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.bold,
              fontSize: isLarge ? 18 : 12,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
