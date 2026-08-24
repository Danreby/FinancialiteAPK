import 'package:flutter/material.dart';

/// Corner-radius scale mirroring financialite's flatter, more contained
/// web aesthetic (site uses 8/12/16px at desktop scale), adapted for touch.
class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 18;
  static const double xxl = 24;
  static const double sheet = 28;
  static const double pill = 999;

  /// Floating bottom-nav pill radius.
  static const double nav = 28;

  /// Signature card shape: one tight corner, the rest open -- a single
  /// asymmetry applied consistently so it reads as a brand shape rather
  /// than a uniform rounded rectangle. Used for primary "money" surfaces
  /// (balance hero, account/bill/goal cards).
  static BorderRadius cardCut({double open = xxl, double tight = xs}) =>
      BorderRadius.only(
        topLeft: Radius.circular(tight),
        topRight: Radius.circular(open),
        bottomLeft: Radius.circular(open),
        bottomRight: Radius.circular(open),
      );
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
    BoxShadow(color: Color(0x1F000000), blurRadius: 10, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, -1)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x24000000), blurRadius: 20, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, -3)),
  ];

  /// Soft-UI raised shadow for the app's primary CTA buttons: a dark
  /// contact shadow plus a colored glow plus a faint highlight -- the same
  /// "raised surface" language as [AppNeumorphic.outset], just carrying
  /// the accent color since a primary button is where color-as-depth is
  /// allowed (never on ambient page/card chrome).
  static List<BoxShadow> buttonPrimary(Color accent) => [
        BoxShadow(color: const Color(0x66000000), blurRadius: 14, offset: const Offset(4, 6)),
        BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 18, offset: const Offset(0, 8)),
        const BoxShadow(color: Color(0x0FFFFFFF), blurRadius: 10, offset: Offset(-4, -4)),
      ];

  static const List<BoxShadow> darkSm = [
    BoxShadow(color: Color(0x40000000), blurRadius: 3, offset: Offset(0, 1)),
  ];

  /// Two-layer "ambient brand light" shadow for primary money cards: a
  /// shallow neutral contact shadow plus a wide, low-alpha shadow tinted
  /// with the theme's primary color -- replaces a hairline border as the
  /// card's definition, reading as designed depth rather than a glow.
  static List<BoxShadow> cardBold(Color primary) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 2,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: primary.withValues(alpha: 0.10),
          blurRadius: 32,
          offset: const Offset(0, 16),
        ),
      ];
}

/// Hairline border helper, using a scheme's cardBorder color.
class AppBorders {
  AppBorders._();

  static BorderSide hairline(Color color) => BorderSide(color: color, width: 1);
}

/// Soft-UI shadow recipes -- the same dual-shadow math the auth screens
/// pioneered, generalized for reuse across the main app on the components
/// where a raised/tactile surface earns its keep (primary buttons, the
/// chart panel, summary tiles) -- deliberately NOT applied to the flat
/// ledger list rows, which stay hairline-divided for scannability. Only
/// meant for dark surfaces (the app's default appearance); on light theme
/// these fall back to [AppShadows.sm]/[AppShadows.md] since a highlight
/// shadow against a white background has no soft-UI effect to give.
class AppNeumorphic {
  AppNeumorphic._();

  /// Raised surface for SMALL elements (~40-60dp: icon buttons, chips).
  /// Tight blur/offset relative to the element's own size -- a wide, soft
  /// blur on a small shape reads as a smudge, not a lift.
  static const List<BoxShadow> outset = [
    BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(3, 3)),
    BoxShadow(color: Color(0x1AFFFFFF), blurRadius: 6, offset: Offset(-2, -2)),
  ];

  /// Raised surface for LARGER panels (chart card, bottom nav, sheets)
  /// where a wider blur still reads as one coherent lift.
  static const List<BoxShadow> outsetLarge = [
    BoxShadow(color: Color(0x59000000), blurRadius: 14, offset: Offset(5, 5)),
    BoxShadow(color: Color(0x14FFFFFF), blurRadius: 14, offset: Offset(-4, -4)),
  ];

  /// Carved-in surface: pressed buttons, inset fields. Same tight scale as
  /// [outset] so a button's pressed state doesn't suddenly look like a
  /// different, bigger component.
  static const List<BoxShadow> inset = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 5,
      offset: Offset(2, 2),
      blurStyle: BlurStyle.inner,
    ),
    BoxShadow(
      color: Color(0x14FFFFFF),
      blurRadius: 5,
      offset: Offset(-2, -2),
      blurStyle: BlurStyle.inner,
    ),
  ];

  /// Color glow reserved for the primary action's raised state -- pairs
  /// with [outset] on the pill CTA, matching the "color only on the one
  /// primary button" rule the rest of the shadow system already follows.
  static List<BoxShadow> outsetColored(Color accent) => [
        const BoxShadow(color: Color(0x59000000), blurRadius: 10, offset: Offset(3, 4)),
        BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6)),
        const BoxShadow(color: Color(0x14FFFFFF), blurRadius: 8, offset: Offset(-3, -3)),
      ];
}
