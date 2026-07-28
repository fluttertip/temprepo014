import 'package:flutter/material.dart';

/// Raw brand color tokens for KothaKhoj v2.
///
/// Screens should NOT read these directly. Pull from
/// `Theme.of(context).colorScheme` or the `context.colors` extension so that
/// light/dark mode works automatically. Isolating the raw palette makes a
/// rebrand a one-file change.
class AppPalette {
  AppPalette._();

  // Brand — a warm, trustworthy emerald that reads as "home" without v1's
  // generic Material green. This is the seed the whole ColorScheme derives from.
  static const Color brand = Color(0xFF0E7C66);
  static const Color brandDark = Color(0xFF0A5E4D);
  static const Color brandLight = Color(0xFF2AA98C);

  // Accent — a confident coral for primary CTAs, favorites, delight moments.
  static const Color accent = Color(0xFFFF6B57);

  // Semantic
  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFF0A400);
  static const Color danger = Color(0xFFE5484D);
  static const Color info = Color(0xFF3E7BFA);

  // Role identity — orients the user in tenant vs landlord, used sparingly.
  static const Color tenant = Color(0xFF3E7BFA);
  static const Color landlord = Color(0xFFFF7A00);

  static const Color rating = Color(0xFFFFB300);

  // Neutral ramp
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF7F8F8);
  static const Color neutral100 = Color(0xFFEFF1F1);
  static const Color neutral200 = Color(0xFFE1E4E4);
  static const Color neutral300 = Color(0xFFCDD2D2);
  static const Color neutral400 = Color(0xFF9BA3A3);
  static const Color neutral500 = Color(0xFF6B7373);
  static const Color neutral600 = Color(0xFF4A5151);
  static const Color neutral700 = Color(0xFF323838);
  static const Color neutral800 = Color(0xFF1E2323);
  static const Color neutral900 = Color(0xFF121616);
}