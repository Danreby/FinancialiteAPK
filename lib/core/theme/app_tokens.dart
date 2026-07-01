import 'package:flutter/material.dart';

/// Corner-radius scale mirroring financialite's flatter, more contained
/// web aesthetic (site uses 8/12/16px at desktop scale), adapted for touch.
class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 10;
  static const double xl = 12;
  static const double xxl = 16;
  static const double sheet = 20;
  static const double pill = 999;
}

/// Spacing scale centralizing the 4px-multiples already used across pages.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Flat, neutral shadows replacing the previous saturated glow shadows.
/// Only [buttonPrimary] carries a (subtle) brand color, matching the web
/// app's rule that color only appears directly under the primary button,
/// never as an ambient page/card glow.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x1A000000), blurRadius: 2, offset: Offset(0, -1)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, -2)),
  ];

  static List<BoxShadow> buttonPrimary(Color accent) => [
        BoxShadow(
          color: accent.withValues(alpha: 0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: accent.withValues(alpha: 0.3),
          blurRadius: 2,
          offset: const Offset(0, -1),
        ),
      ];

  static const List<BoxShadow> darkSm = [
    BoxShadow(color: Color(0x40000000), blurRadius: 3, offset: Offset(0, 1)),
  ];
}

/// Hairline border helper, using a scheme's cardBorder color.
class AppBorders {
  AppBorders._();

  static BorderSide hairline(Color color) => BorderSide(color: color, width: 1);
}
