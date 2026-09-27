import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../../features/emergency/presentation/widgets/sos_activation_dialog.dart';

class EmergencyButton extends StatefulWidget {
  final VoidCallback onTrigger;
  final bool isLarge;

  const EmergencyButton({
    super.key,
    required this.onTrigger,
    this.isLarge = true,
  });

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  late AnimationController _holdController;
  bool _isHolding = false;
  bool _hasTriggered = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation for ambient halo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3-second hold controller matching Stitch design
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_hasTriggered) {
        _hasTriggered = true;
        HapticFeedback.heavyImpact();
        widget.onTrigger();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _holdController.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    setState(() {
      _isHolding = true;
      _hasTriggered = false;
    });
    HapticFeedback.lightImpact();
    _holdController.forward();
  }

  void _onPointerUp(PointerUpEvent event) {
    _cancelHold();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _cancelHold();
  }

  void _cancelHold() {
    if (_isHolding) {
      setState(() {
        _isHolding = false;
      });
      if (!_hasTriggered) {
        _holdController.reverse();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final ringSize = widget.isLarge ? 150.0 : 120.0;
    final buttonSize = widget.isLarge ? 116.0 : 92.0;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Listener(
            onPointerDown: _onPointerDown,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerCancel,
            child: GestureDetector(
              onTap: () {
                // When tapped/pressed, launch the emergency SOS activation countdown & direct trigger
                if (!_hasTriggered) {
                  SosActivationDialog.show(context, onActivated: widget.onTrigger);
                }
              },
              child: SizedBox(
                width: ringSize + 30,
                height: ringSize + 30,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Static Outer Ambient Pulsing Halo
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isHolding ? 1.08 : _scaleAnimation.value,
                          child: Container(
                            width: ringSize + 24,
                            height: ringSize + 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.errorContainer.withAlpha(
                                _isHolding ? 160 : 110,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.emergencyRed.withAlpha(
                                    _isHolding ? 90 : 50,
                                  ),
                                  blurRadius: 28,
                                  spreadRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // 2. Circular Progress Track & Fill Ring (3-second hold)
                    AnimatedBuilder(
                      animation: _holdController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(ringSize, ringSize),
                          painter: _SosProgressPainter(
                            progress: _holdController.value,
                            trackColor: AppColors.errorContainer,
                            progressColor: AppColors.emergencyRed,
                          ),
                        );
                      },
                    ),

                    // 3. Tactile Circular SOS Button
                    AnimatedScale(
                      scale: _isHolding ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        width: buttonSize,
                        height: buttonSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.emergencyRed,
                              Color(0xFFB91C1C),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emergencyRed.withAlpha(120),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shield_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isHolding ? 'HOLDING' : 'HOLD',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const Text(
                                'FOR SOS',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_clock_rounded,
                size: 15,
                color: AppColors.onSurfaceVariant,
              ),
              SizedBox(width: 5),
              Text(
                '3-Second Press & Hold',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const SizedBox(
            width: 260,
            child: Text(
              'Protects against false triggers while ensuring immediate siren and SMS dispatch to contacts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SosProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _SosProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;

    // Track circle
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SosProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
