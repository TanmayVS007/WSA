import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      title: 'Wear the Safety Band',
      description:
          'A lightweight wearable band with real-time biometric and motion sensors designed for discreet, continuous personal protection.',
      icon: Icons.watch_outlined,
      tag: 'HARDWARE SENSORS',
    ),
    _OnboardingItem(
      title: 'Instant Manual SOS',
      description:
          'Press the physical SOS button on your band or in the app anytime you feel unsafe to trigger immediate emergency workflows.',
      icon: Icons.emergency_rounded,
      tag: 'MANUAL TRIGGER',
    ),
    _OnboardingItem(
      title: 'Automatic Anomaly Detection',
      description:
          'The band detects anomalous heart rate surges combined with shock or fall motion patterns, prompting a confirmation countdown before dispatch.',
      icon: Icons.health_and_safety_outlined,
      tag: 'SMART DETECTION',
    ),
    _OnboardingItem(
      title: 'Live Location Sharing',
      description:
          'During active emergencies, your high-accuracy GNSS location is broadcast securely to authorized recipients.',
      icon: Icons.location_on_outlined,
      tag: 'GNSS SATELLITE & CELLULAR',
    ),
    _OnboardingItem(
      title: 'Trusted Contact Alerts',
      description:
          'Your family and emergency contacts receive instant high-priority notifications, live status, and one-tap calling access.',
      icon: Icons.people_outline_rounded,
      tag: 'GUARDIAN NETWORK',
    ),
    _OnboardingItem(
      title: 'Opt-in Nearby Helpers',
      description:
          'Verified community helpers nearby receive approximate alerts without exposing your private identity or phone number.',
      icon: Icons.volunteer_activism_outlined,
      tag: 'COMMUNITY SAFETY',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      AppLogo.badge(size: 28),
                      SizedBox(width: 8),
                      Text(
                        'AEGIS',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Skip', style: TextStyle(fontSize: 15)),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDarkElevated
                                : AppColors.primaryPurpleLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            size: 64,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.tag,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primaryPurple
                          : Colors.grey.withAlpha(80),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  if (_currentPage > 0) ...[
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: _currentPage == _items.length - 1
                          ? 'Get Started'
                          : 'Next',
                      onPressed: () {
                        if (_currentPage == _items.length - 1) {
                          context.go('/login');
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final String tag;

  const _OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.tag,
  });
}
