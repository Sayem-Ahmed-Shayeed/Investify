import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'poppins';

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: _fontFamily,
    primaryColor: AppColors.primaryLight,
    scaffoldBackgroundColor: AppColors.gradientBottomLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimaryLight,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimaryLight,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimaryLight,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimaryLight,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimaryLight,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimaryLight,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textSecondaryLight,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textSecondaryLight,
        fontSize: 12,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFillLight,
      hintStyle: const TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textSecondaryLight,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonLight,
        foregroundColor: AppColors.buttonTextLight,
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimaryLight,
        textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.iconLight),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.primaryLight,
      surface: AppColors.cardLight,
      onPrimary: AppColors.buttonTextLight,
      onSecondary: AppColors.textPrimaryLight,
      onSurface: AppColors.textPrimaryLight,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: _fontFamily,
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.gradientBottomDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimaryDark,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimaryDark,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimaryDark,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimaryDark,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimaryDark,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textPrimaryDark,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textSecondaryDark,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textSecondaryDark,
        fontSize: 12,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFillDark,
      hintStyle: const TextStyle(
        fontFamily: _fontFamily,
        color: AppColors.textSecondaryDark,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonDark,
        foregroundColor: AppColors.buttonTextDark,
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimaryDark,
        textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.iconDark),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.primaryDark,
      surface: AppColors.cardDark,
      onPrimary: AppColors.buttonTextDark,
      onSecondary: AppColors.textPrimaryDark,
      onSurface: AppColors.textPrimaryDark,
    ),
  );
}
