import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/emergency_provider.dart';

class SosActivationDialog extends ConsumerStatefulWidget {
  final VoidCallback? onActivated;

  const SosActivationDialog({
    super.key,
    this.onActivated,
  });

  /// Displays the interactive 3-second SOS Activation Dialog.
  static Future<void> show(BuildContext context, {VoidCallback? onActivated}) {
    HapticFeedback.heavyImpact();
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: SosActivationDialog(onActivated: onActivated),
      ),
    );
  }

  @override
  ConsumerState<SosActivationDialog> createState() =>
      _SosActivationDialogState();
}

class _SosActivationDialogState extends ConsumerState<SosActivationDialog>
    with SingleTickerProviderStateMixin {
  int _secondsRemaining = 3;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  bool _isActivating = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        _activateSos();
      }
    });
  }

  Future<void> _activateSos() async {
    if (_isActivating) return;
    setState(() {
      _isActivating = true;
    });

    _timer?.cancel();
    HapticFeedback.heavyImpact();
    widget.onActivated?.call();

    await ref.read(emergencyNotifierProvider.notifier).triggerManualSos();

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      try {
        context.push('/emergency');
      } catch (_) {}
    }
  }

  void _cancel() {
    _timer?.cancel();
    HapticFeedback.selectionClick();
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1F1010) : const Color(0xFFFFF5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.emergencyRed, width: 2),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing Beacon Icon with Countdown Badge
          ScaleTransition(
            scale: _scaleAnimation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.emergencyRed.withAlpha(40),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emergencyRed.withAlpha(80),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.emergencyRed, Color(0xFF991B1B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$_secondsRemaining',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            '🚨 ACTIVATING SOS BEACON',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: AppColors.emergencyRed,
            ),
          ),
          const SizedBox(height: 10),

          const Text(
            'Broadcasting distress signal, sending live GPS to guardians & alerting safety relays in:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            '$_secondsRemaining SECONDS',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.emergencyRed,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),

          // Immediate Activation Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergencyRed,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _isActivating ? null : _activateSos,
              icon: _isActivating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.emergency_rounded, size: 20),
              label: Text(
                _isActivating ? 'ACTIVATING...' : 'ACTIVATE SOS NOW',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Cancel Button (False Alarm Prevention)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white70 : Colors.black87,
                side: BorderSide(
                  color: isDark ? AppColors.cardBorderDark : const Color(0xFFCBD5E1),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _cancel,
              child: const Text(
                'CANCEL (I\'M SAFE)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
