import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/aegis_bottom_nav.dart';
import '../../../../core/widgets/aegis_top_bar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/status_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      appBar: const AegisTopBar(
        title: 'Profile',
        showBackButton: true,
        showProfile: false,
      ),
      bottomNavigationBar: const AegisBottomNav(currentIndex: 4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.primaryPurpleLight,
                      child: Text(
                        (user?.name.isNotEmpty ?? false) ? user!.name[0] : 'U',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.name ?? 'Ananya Sharma',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurpleLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user?.role.name.toUpperCase() ?? 'WEARABLE OWNER',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              StatusCard(
                title: 'Account Information',
                child: Column(
                  children: [
                    _buildRow('Email Address', user?.email ?? 'ananya@example.com'),
                    const Divider(height: 16),
                    _buildRow('Phone Number', user?.phone ?? '+91 98765 43210'),
                    const Divider(height: 16),
                    _buildRow('Paired Device ID', user?.deviceId ?? 'wsb_esp32_78a1'),
                    const Divider(height: 16),
                    _buildRow('Account Created', '15 Aug 2026'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              AppButton(
                text: 'Sign Out',
                variant: AppButtonVariant.outline,
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
              const SizedBox(height: 32),

              Center(
                child: Column(
                  children: [
                    const AppLogo(
                      size: 36,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'AEGIS BAND COMPANION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Version 1.0.0 (WSB-001 Edition)',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
