import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable application logo widget that loads `applogo.png` from assets
/// with graceful fallback handling and configurable presentation styles.
class AppLogo extends StatelessWidget {
  /// Primary asset path in lib/assets/
  static const String assetPath = 'lib/assets/applogo.png';
  /// Secondary fallback asset path in assets/
  static const String fallbackAssetPath = 'assets/applogo.png';

  final double size;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.size = 48,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.backgroundColor,
    this.padding,
    this.boxShadow,
    this.border,
    this.fit = BoxFit.contain,
  });

  /// Named constructor for a circular logo avatar/badge
  const AppLogo.circle({
    super.key,
    this.size = 48,
    this.width,
    this.height,
    this.backgroundColor,
    this.padding,
    this.boxShadow,
    this.border,
    this.fit = BoxFit.contain,
  })  : borderRadius = null,
        shape = BoxShape.circle;

  /// Named constructor for a compact app bar / header badge
  const AppLogo.badge({
    super.key,
    this.size = 32,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    Color? backgroundColor,
    this.fit = BoxFit.contain,
  })  : width = size,
        height = size,
        shape = BoxShape.rectangle,
        backgroundColor = backgroundColor ?? AppColors.primary,
        padding = const EdgeInsets.all(4),
        boxShadow = null,
        border = null;

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? size;
    final effectiveHeight = height ?? size;

    Widget imageWidget = Image.asset(
      assetPath,
      width: effectiveWidth,
      height: effectiveHeight,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to secondary path if primary fails
        return Image.asset(
          fallbackAssetPath,
          width: effectiveWidth,
          height: effectiveHeight,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            // Fallback icon if image asset decoding fails in test environment
            return Icon(
              Icons.shield_rounded,
              size: effectiveHeight * 0.6,
              color: Colors.white,
            );
          },
        );
      },
    );

    if (shape == BoxShape.circle) {
      imageWidget = ClipOval(child: imageWidget);
    } else if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    if (backgroundColor != null || border != null || boxShadow != null || padding != null) {
      return Container(
        width: effectiveWidth,
        height: effectiveHeight,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: shape,
          borderRadius: shape == BoxShape.circle ? null : borderRadius,
          border: border,
          boxShadow: boxShadow,
        ),
        child: Center(child: imageWidget),
      );
    }

    return imageWidget;
  }
}
