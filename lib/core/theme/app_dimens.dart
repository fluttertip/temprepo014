/// Spacing, radius, elevation and breakpoint tokens on a consistent 4pt grid.
///
/// v1's `AppSizes` mixed arbitrary values across screens. A single semantic
/// scale keeps vertical rhythm consistent and makes the app feel designed.
class AppSpacing {
  AppSpacing._();

  static const double x2s = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double x2l = 32;
  static const double x3l = 48;
  static const double x4l = 64;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

class AppIconSize {
  AppIconSize._();

  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
  static const double xl = 48;
}

/// Responsive breakpoints. v1 was locked to portrait phone and showed a fake
/// mockup on web; v2 is layout-aware so tablet/web get real treatment.
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 905;
  static const double desktop = 1240;
}

/// Motion durations — centralized so animations feel cohesive.
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}