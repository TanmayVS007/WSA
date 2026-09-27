import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import 'app_logo.dart';
import '../../features/emergency/presentation/widgets/sos_activation_dialog.dart';

class AegisTopBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showSosButton;
  final bool showProfile;

  const AegisTopBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showSosButton = true,
    this.showProfile = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1C30).withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Wearable Connectivity & Battery Telemetry Bar
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            //   color: isDark
            //       ? AppColors.surfaceDarkElevated
            //       : AppColors.surfaceContainerLow.withAlpha(180),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Row(
            //         children: [
            //           // Pulsing connection dot
            //           _PulsingDot(isActive: isConnected),
            //           const SizedBox(width: 8),
            //           Text(
            //             isConnected ? 'WSB-001 CONNECTED' : 'WSB-001 SEARCHING',
            //             style: TextStyle(
            //               fontSize: 11,
            //               fontWeight: FontWeight.w700,
            //               letterSpacing: 0.8,
            //               color: isDark
            //                   ? AppColors.textSecondaryDark
            //                   : AppColors.onSurfaceVariant,
            //             ),
            //           ),
            //         ],
            //       ),
            //       Row(
            //         children: [
            //           Icon(
            //             batteryLevel > 80
            //                 ? Icons.battery_full_rounded
            //                 : batteryLevel > 40
            //                     ? Icons.battery_5_bar_rounded
            //                     : Icons.battery_alert_rounded,
            //             size: 15,
            //             color: batteryLevel > 20
            //                 ? AppColors.tertiary
            //                 : AppColors.emergencyRed,
            //           ),
            //           const SizedBox(width: 4),
            //           Text(
            //             '$batteryLevel%',
            //             style: TextStyle(
            //               fontSize: 12,
            //               fontWeight: FontWeight.w700,
            //               color: batteryLevel > 20
            //                   ? AppColors.tertiary
            //                   : AppColors.emergencyRed,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),

            // 2. Main Title Bar
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (showBackButton)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/dashboard');
                            }
                          },
                        )
                      else ...[
                        Container(
                          width: 32,
                          height: 32,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(60),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const AppLogo(
                            size: 26,
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (showSosButton) ...[
                        Material(
                          color: AppColors.emergencyRed,
                          borderRadius: BorderRadius.circular(20),
                          elevation: 2,
                          shadowColor: AppColors.emergencyRed.withAlpha(90),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => SosActivationDialog.show(context),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.emergency_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'SOS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (showProfile)
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withAlpha(40),
                                width: 1.5,
                              ),
                              color: AppColors.surfaceContainerHigh,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
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

class _PulsingDot extends StatefulWidget {
  final bool isActive;
  const _PulsingDot({required this.isActive});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive ? AppColors.tertiary : AppColors.warningAmber;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withAlpha((_controller.value * 180).toInt()),
                blurRadius: 6,
                spreadRadius: 2 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
