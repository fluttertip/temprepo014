import 'package:flutter/material.dart';

/// Type scale for KothaKhoj v2, mapped onto Material 3 `TextTheme` slots.
///
/// v1 hardcoded colors into every TextStyle, which broke dark mode. Here we
/// define weights/sizes/letter-spacing only — color comes from the active
/// ColorScheme via `onSurface`, applied in `app_theme.dart`. Uses the bundled
/// system font stack for zero extra app-size cost; swap `fontFamily` here to
/// adopt Google Fonts (e.g. 'Inter') in one place.
class AppTypography {
  AppTypography._();

  static const String? fontFamily = null; // set to 'Inter' once bundled

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 40, height: 1.1, fontWeight: FontWeight.w700, letterSpacing: -0.5),
    displayMedium: TextStyle(fontSize: 32, height: 1.15, fontWeight: FontWeight.w700, letterSpacing: -0.5),
    displaySmall: TextStyle(fontSize: 28, height: 1.2, fontWeight: FontWeight.w700, letterSpacing: -0.3),
    headlineMedium: TextStyle(fontSize: 24, height: 1.25, fontWeight: FontWeight.w700, letterSpacing: -0.2),
    headlineSmall: TextStyle(fontSize: 20, height: 1.3, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 18, height: 1.3, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, height: 1.45, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, height: 1.2, fontWeight: FontWeight.w600, letterSpacing: 0.1),
    labelMedium: TextStyle(fontSize: 12, height: 1.2, fontWeight: FontWeight.w600, letterSpacing: 0.3),
    labelSmall: TextStyle(fontSize: 11, height: 1.2, fontWeight: FontWeight.w500, letterSpacing: 0.4),
  );
}