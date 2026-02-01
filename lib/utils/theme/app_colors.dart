import 'package:flutter/material.dart';

/// App color constants for light and dark themes
class AppColors {
  AppColors._();

  // ===== Core accents (from provided UI) =====
  static const Color primaryLight = Color(0xFF90D1EC); // soft cyan (accent)
  static const Color primaryDark = Color(
    0xFF90D1EC,
  ); // keep accent same for dark theme

  // ===== Background Gradient Colors (Light Sky Theme) =====
  static const Color gradientTopLight = Color(0xFF90D1EC);
  static const Color gradientBottomLight = Color(0xFFD4E1E8);

  // ===== Background Gradient Colors (Dark Theme) =====
  static const Color gradientTopDark = Color(0xFF1E1E1E);
  static const Color gradientBottomDark = Color(0xFF121212);

  // ===== Surfaces / Cards =====
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1C1C1C);

  // ===== Scaffold / Canvas (aliases) =====
  static const Color scaffoldBackgroundLight = gradientBottomLight;
  static const Color scaffoldBackgroundDark = gradientBottomDark;
  static const Color canvasLight = cardLight;
  static const Color canvasDark = cardDark;

  // ===== Input Fields =====
  static const Color inputFillLight = Color(0xFFF3F6F7);
  static const Color inputFillDark = Color(0xFF2A2A2A);
  static const Color inputBorderLight = Color(0xFFE0E0E0);
  static const Color inputBorderDark = Color(0xFF424242);

  // ===== Text =====
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFFA7A7A7);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // ===== Buttons =====
  static const Color buttonLight = Color(0xFF212121); // dark CTA in light theme
  static const Color buttonTextLight = Color(0xFFFFFFFF);
  static const Color buttonDark = Color(
    0xFF90D1EC,
  ); // accent button in dark theme
  static const Color buttonTextDark = Color(0xFF212121);

  // ===== Icon Colors =====
  static const Color iconLight = Color(0xFF212121);
  static const Color iconDark = Color(0xFFFFFFFF);

  // ===== Borders & Dividers =====
  static const Color cardBorderLight = Color(0xFFE0E0E0);
  static const Color cardBorderDark = Color(0xFF424242);
  static const Color dividerLight = Color(0xFFEBF0F3);
  static const Color dividerDark = Color(0xFF2E2E2E);

  // ===== Accents / Helpers =====
  static const Color accentLight = Color(0xFFAEDDF1); // pale blue accent
  static const Color accentDark = Color(0xFFAEDDF1);
  static const Color mutedLight = Color(0xFFA7A7A7);
  static const Color mutedDark = Color(0xFF8E8E8E);

  // ===== Semantic aliases (optional convenience) =====
  static const Color backgroundLight = gradientBottomLight;
  static const Color backgroundDark = gradientBottomDark;
  static const Color surfaceLight = cardLight;
  static const Color surfaceDark = cardDark;
}
