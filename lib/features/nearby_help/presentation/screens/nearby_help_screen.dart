import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_card.dart';

class NearbyHelpScreen extends ConsumerStatefulWidget {
  const NearbyHelpScreen({super.key});

  @override
  ConsumerState<NearbyHelpScreen> createState() => _NearbyHelpScreenState();
}

class _NearbyHelpScreenState extends ConsumerState<NearbyHelpScreen> {
  bool _isVolunteerHelper = true;
  double _searchRadiusKm = 2.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Nearby Help'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Privacy Protection Notice (Section 20 & 32)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.primaryPurpleLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryPurple.withAlpha(80)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.privacy_tip_outlined, color: AppColors.primaryPurple, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Strict Privacy Boundary',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Nearby helpers only receive sanitized approximate locations (within ~500m radius). Personal names, phone numbers, and full emergency history are never disclosed.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Opt-in Toggle Card
              StatusCard(
                title: 'Community Volunteer Safety Network',
                trailing: Switch.adaptive(
                  value: _isVolunteerHelper,
                  activeTrackColor: AppColors.safeGreen,
                  onChanged: (val) => setState(() => _isVolunteerHelper = val),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isVolunteerHelper
                          ? 'Status: Opted in. You can receive anonymous assistance requests if someone within ${_searchRadiusKm.toStringAsFixed(1)}km triggers an emergency.'
                          : 'Status: Opted out. You will not receive nearby community alerts.',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Search Radius: ${_searchRadiusKm.toStringAsFixed(1)} km',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Slider(
                      value: _searchRadiusKm,
                      min: 0.5,
                      max: 5.0,
                      divisions: 9,
                      activeColor: AppColors.primaryPurple,
                      onChanged: _isVolunteerHelper
                          ? (val) => setState(() => _searchRadiusKm = val)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'ACTIVE NEARBY ALERTS IN YOUR AREA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 10),

              // Demonstration of Sanitized Scoped Alert
              Card(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warningAmberLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'APPROXIMATE ALERT • 450M AWAY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warningAmber,
                              ),
                            ),
                          ),
                          const Text('3m ago', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Someone nearby requested emergency verification',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Location: Near FC Road, Shivajinagar area (~450m from your current zone). Private identity protected.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Alert dismissed.')),
                                );
                              },
                              child: const Text('Decline'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryPurple,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Alert acknowledged. Approaching safe public contact point.'),
                                  ),
                                );
                              },
                              child: const Text('Acknowledge'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
