import 'package:flutter/material.dart';

/// Centralized color palette for the Women Safety Band (Aegis Band Companion) system.
/// Defined based on the Stitch UI/UX design specifications (Project 7440015000074118395).
class AppColors {
  AppColors._();

  // Stitch Primary & Brand Tones (Deep Indigo)
  static const Color primary = Color(0xFF4338CA);
  static const Color primaryDark = Color(0xFF2A14B4);
  static const Color primaryContainer = Color(0xFF4338CA);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFC1BEFF);
  static const Color primaryFixed = Color(0xFFE3DFFF);
  static const Color primaryFixedDim = Color(0xFFC3C0FF);

  // Stitch Secondary Tones (Obsidian Navy & Slate)
  static const Color secondary = Color(0xFF0F172A);
  static const Color secondarySlate = Color(0xFF565E74);
  static const Color secondaryContainer = Color(0xFFDAE2FD);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF5C647A);
  static const Color secondaryFixed = Color(0xFFDAE2FD);
  static const Color secondaryFixedDim = Color(0xFFBEC6E0);

  // Stitch Tertiary / Safe & Connected Tones (Safe Emerald)
  static const Color tertiary = Color(0xFF10B981);
  static const Color tertiaryDark = Color(0xFF00442D);
  static const Color tertiaryContainer = Color(0xFF005E3F);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF4DDDA2);
  static const Color tertiaryFixed = Color(0xFF6FFBBE);
  static const Color tertiaryFixedDim = Color(0xFF4EDEA3);
  static const Color onTertiaryFixed = Color(0xFF002113);
  static const Color onTertiaryFixedVariant = Color(0xFF005236);

  // Stitch Emergency / SOS / Error Tones (Emergency Crimson)
  static const Color emergencyRed = Color(0xFFEF4444);
  static const Color emergencyRedDark = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color emergencyRedLight = Color(0xFFFFEBEE);

  // Stitch Warning & Pre-alert Tones (Amber)
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningAmberLight = Color(0xFFFFF8E1);

  // Stitch Canvas & Surfaces (Clean Medical / Protective Light Canvas)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceDim = Color(0xFFCBDBF5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);

  // Stitch Typography & Borders
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF464554);
  static const Color outline = Color(0xFF777586);
  static const Color outlineVariant = Color(0xFFC7C4D7);
  static const Color inverseSurface = Color(0xFF213145);
  static const Color inverseOnSurface = Color(0xFFEAF1FF);

  // Backward Compatibility Aliases for Existing Widgets
  static const Color safeGreen = tertiary;
  static const Color safeGreenLight = Color(0xFFE8F5E9);
  static const Color primaryPurple = primary;
  static const Color primaryPurpleDark = primaryDark;
  static const Color primaryPurpleLight = Color(0xFFEDE7F6);
  static const Color accentRose = primary;
  static const Color backgroundLight = background;
  static const Color surfaceLight = surfaceContainerLowest;
  static const Color cardBorderLight = outlineVariant;
  static const Color textPrimaryLight = onSurface;
  static const Color textSecondaryLight = onSurfaceVariant;
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color unknownGrey = outline;
  static const Color unknownGreyLight = surfaceContainerLow;

  // Dark Theme Neutral Colors
  static const Color backgroundDark = Color(0xFF0B131F);
  static const Color surfaceDark = Color(0xFF131D2E);
  static const Color surfaceDarkElevated = Color(0xFF1E293B);
  static const Color cardBorderDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color dividerDark = Color(0xFF1E293B);

  // Telemetry indicators
  static const Color batteryNormal = tertiary;
  static const Color batteryLow = warningAmber;
  static const Color batteryCritical = emergencyRed;
}

