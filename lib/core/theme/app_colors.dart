import 'package:flutter/material.dart';

enum AppColorScheme { rose, forest, black, gold, lavender, midnight }

class ThemeColors {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color headerBackground;
  final Color sidebarBackground;
  final Color surface;
  final Color surfaceVariant;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;
  final Color hint;
  final Color divider;
  final Color inputFill;
  final Color chipBackground;
  final Color cardBorder;
  final Color income;
  final Color expense;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Gradient primaryGradient;
  final Gradient cardGradient;
  final Gradient heroGradient;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> elevatedShadow;

  const ThemeColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.headerBackground,
    required this.sidebarBackground,
    required this.surface,
    required this.surfaceVariant,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.hint,
    required this.divider,
    required this.inputFill,
    required this.chipBackground,
    required this.cardBorder,
    required this.income,
    required this.expense,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.primaryGradient,
    required this.cardGradient,
    required this.heroGradient,
    required this.cardShadow,
    required this.elevatedShadow,
  });

  ThemeColors copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? headerBackground,
    Color? sidebarBackground,
    Color? surface,
    Color? surfaceVariant,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? error,
    Color? success,
    Color? warning,
    Color? info,
    Color? hint,
    Color? divider,
    Color? inputFill,
    Color? chipBackground,
    Color? cardBorder,
    Color? income,
    Color? expense,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Gradient? primaryGradient,
    Gradient? cardGradient,
    Gradient? heroGradient,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? elevatedShadow,
  }) {
    return ThemeColors(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      headerBackground: headerBackground ?? this.headerBackground,
      sidebarBackground: sidebarBackground ?? this.sidebarBackground,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      hint: hint ?? this.hint,
      divider: divider ?? this.divider,
      inputFill: inputFill ?? this.inputFill,
      chipBackground: chipBackground ?? this.chipBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      cardGradient: cardGradient ?? this.cardGradient,
      heroGradient: heroGradient ?? this.heroGradient,
      cardShadow: cardShadow ?? this.cardShadow,
      elevatedShadow: elevatedShadow ?? this.elevatedShadow,
    );
  }
}

// ---------------------------------------------------------------------------
// Helper builders – keep common light / dark values in one place.
//
// Chrome (background/headerBackground/sidebarBackground/divider/cardBorder/
// inputFill) defaults to a neutral, brand-agnostic palette in light mode,
// mirroring financialite's web app where the topbar/sidebar/card borders are
// always white/neutral-gray regardless of the active accent color -- only
// `chipBackground` and the gradients stay lightly brand-tinted.
// ---------------------------------------------------------------------------

ThemeColors _buildLightTheme({
  required Color primary,
  required Color primaryLight,
  required Color primaryDark,
  required Color secondary,
  required Color accent,
  required Color chipBackground,
  required List<Color> cardGradientColors,
  required List<Color> heroGradientColors,
  required List<BoxShadow> cardShadow,
  required List<BoxShadow> elevatedShadow,
  Color background = const Color(0xFFFAFAFA),
  Color headerBackground = const Color(0xFFFFFFFF),
  Color sidebarBackground = const Color(0xFFFFFFFF),
  Color surfaceVariant = const Color(0xFFF1F3F8),
  Color onSurface = const Color(0xFF18181B),
  Color divider = const Color(0xFFE5E5E5),
  Color inputFill = const Color(0xFFFFFFFF),
  Color cardBorder = const Color(0xFFE5E5E5),
  Color shimmerBase = const Color(0xFFE5E7EB),
  Color shimmerHighlight = const Color(0xFFF9FAFB),
}) {
  return ThemeColors(
    primary: primary,
    primaryLight: primaryLight,
    primaryDark: primaryDark,
    secondary: secondary,
    accent: accent,
    background: background,
    headerBackground: headerBackground,
    sidebarBackground: sidebarBackground,
    surface: const Color(0xFFFFFFFF),
    surfaceVariant: surfaceVariant,
    onSurface: onSurface,
    onSurfaceVariant: const Color(0xFF52525B),
    error: const Color(0xFFEF4444),
    success: const Color(0xFF22C55E),
    warning: const Color(0xFFF59E0B),
    info: const Color(0xFF3B82F6),
    hint: const Color(0xFFA1A1AA),
    divider: divider,
    inputFill: inputFill,
    chipBackground: chipBackground,
    cardBorder: cardBorder,
    income: const Color(0xFF16A34A),
    expense: const Color(0xFFDC2626),
    shimmerBase: shimmerBase,
    shimmerHighlight: shimmerHighlight,
    primaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [accent, primaryDark],
    ),
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: cardGradientColors,
    ),
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: heroGradientColors,
    ),
    cardShadow: cardShadow,
    elevatedShadow: elevatedShadow,
  );
}

ThemeColors _buildDarkTheme({
  required Color primary,
  required Color primaryLight,
  required Color primaryDark,
  required Color secondary,
  required Color accent,
  required Color background,
  required Color surface,
  required Color surfaceVariant,
  required Color chipBackground,
  required Color divider,
  required List<Color> cardGradientColors,
  required List<Color> heroGradientColors,
  required List<BoxShadow> cardShadow,
  required List<BoxShadow> elevatedShadow,
  List<Color>? primaryGradientColors,
  Color onSurface = const Color(0xFFF4F4F5),
  Color onSurfaceVariant = const Color(0xFFA1A1AA),
  Color hint = const Color(0xFF71717A),
  Color? inputFill,
  Color? cardBorder,
  Color? shimmerBase,
  Color? shimmerHighlight,
}) {
  return ThemeColors(
    primary: primary,
    primaryLight: primaryLight,
    primaryDark: primaryDark,
    secondary: secondary,
    accent: accent,
    background: background,
    headerBackground: surface,
    sidebarBackground: surface,
    surface: surface,
    surfaceVariant: surfaceVariant,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    error: const Color(0xFFF87171),
    success: const Color(0xFF34D399),
    warning: const Color(0xFFFBBF24),
    info: const Color(0xFF60A5FA),
    hint: hint,
    divider: divider,
    inputFill: inputFill ?? surface,
    chipBackground: chipBackground,
    cardBorder: cardBorder ?? divider,
    income: const Color(0xFF34D399),
    expense: const Color(0xFFF87171),
    shimmerBase: shimmerBase ?? surfaceVariant,
    shimmerHighlight: shimmerHighlight ?? divider,
    primaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: primaryGradientColors ?? [primary, primaryDark],
    ),
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: cardGradientColors,
    ),
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: heroGradientColors,
    ),
    cardShadow: cardShadow,
    elevatedShadow: elevatedShadow,
  );
}

// ---------------------------------------------------------------------------
// Reusable shadow presets. Flat and neutral for cards/ambient use; only
// [_elevatedShadow] carries brand color, and only for the primary button --
// never as a page/card glow (mirrors financialite web's rule that color only
// appears directly under `.themed-button-primary`).
// ---------------------------------------------------------------------------

List<BoxShadow> _defaultLightCardShadow() => [
      BoxShadow(
        color: const Color(0xFF1A1D26).withValues(alpha: 0.05),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: const Color(0xFF1A1D26).withValues(alpha: 0.02),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];

List<BoxShadow> _cardShadow(Color color, double alpha) => [
      BoxShadow(
        color: color.withValues(alpha: alpha),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];

List<BoxShadow> _elevatedShadow(Color color, double alpha) => [
      BoxShadow(
        color: color.withValues(alpha: alpha),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];

// ---------------------------------------------------------------------------
// Extension – light & dark getters
// ---------------------------------------------------------------------------

extension AppColorSchemeExtension on AppColorScheme {
  ThemeColors get light {
    switch (this) {
      case AppColorScheme.rose:
        // Exact mirror of financialite's web rose palette
        // (resources/js/Constants/theme.js + resources/css/app.css).
        return _buildLightTheme(
          primary: const Color(0xFFBE123C),
          primaryLight: const Color(0xFFFDA4AF),
          primaryDark: const Color(0xFF9F1239),
          secondary: const Color(0xFFE11D48),
          accent: const Color(0xFFF43F5E),
          chipBackground: const Color(0xFFFEF2F2),
          cardGradientColors: const [Color(0xFFFFFFFF), Color(0xFFFEF2F2)],
          heroGradientColors: const [Color(0xFFBE123C), Color(0xFF9F1239)],
          cardShadow: _defaultLightCardShadow(),
          elevatedShadow: _elevatedShadow(const Color(0xFFF43F5E), 0.3),
        );
      case AppColorScheme.forest:
        return _buildLightTheme(
          primary: const Color(0xFF059669),
          primaryLight: const Color(0xFF6EE7B7),
          primaryDark: const Color(0xFF047857),
          secondary: const Color(0xFF34D399),
          accent: const Color(0xFF2DD4BF),
          chipBackground: const Color(0xFFECFDF5),
          cardGradientColors: const [Color(0xFFFFFFFF), Color(0xFFECFDF5)],
          heroGradientColors: const [Color(0xFF059669), Color(0xFF047857)],
          cardShadow: _defaultLightCardShadow(),
          elevatedShadow: _elevatedShadow(const Color(0xFF2DD4BF), 0.3),
        );
      case AppColorScheme.black:
        return _buildLightTheme(
          primary: const Color(0xFF1F2937),
          primaryLight: const Color(0xFF6B7280),
          primaryDark: const Color(0xFF111827),
          secondary: const Color(0xFF374151),
          accent: const Color(0xFF4B5563),
          onSurface: const Color(0xFF111827),
          chipBackground: const Color(0xFFF3F4F6),
          cardGradientColors: const [Color(0xFFFFFFFF), Color(0xFFF3F4F6)],
          heroGradientColors: const [Color(0xFF1F2937), Color(0xFF111827)],
          cardShadow: _defaultLightCardShadow(),
          elevatedShadow: _elevatedShadow(const Color(0xFF1F2937), 0.3),
        );
      case AppColorScheme.gold:
        return _buildLightTheme(
          primary: const Color(0xFFD97706),
          primaryLight: const Color(0xFFFCD34D),
          primaryDark: const Color(0xFFB45309),
          secondary: const Color(0xFFF59E0B),
          accent: const Color(0xFFEF8C00),
          background: const Color(0xFFFFFBEB),
          chipBackground: const Color(0xFFFEF9C3),
          cardGradientColors: const [Color(0xFFFFFFFF), Color(0xFFFFFBEB)],
          heroGradientColors: const [Color(0xFFD97706), Color(0xFFB45309)],
          cardShadow: _defaultLightCardShadow(),
          elevatedShadow: _elevatedShadow(const Color(0xFFD97706), 0.3),
        );
      case AppColorScheme.lavender:
        return _buildLightTheme(
          primary: const Color(0xFF7C3AED),
          primaryLight: const Color(0xFFC4B5FD),
          primaryDark: const Color(0xFF6D28D9),
          secondary: const Color(0xFF8B5CF6),
          accent: const Color(0xFF9333EA),
          chipBackground: const Color(0xFFEDE9FE),
          cardGradientColors: const [Color(0xFFFFFFFF), Color(0xFFEDE9FE)],
          heroGradientColors: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
          cardShadow: _defaultLightCardShadow(),
          elevatedShadow: _elevatedShadow(const Color(0xFF7C3AED), 0.3),
        );
      case AppColorScheme.midnight:
        return _buildLightTheme(
          primary: const Color(0xFF1E40AF),
          primaryLight: const Color(0xFF93C5FD),
          primaryDark: const Color(0xFF1E3A8A),
          secondary: const Color(0xFF3B82F6),
          accent: const Color(0xFF2563EB),
          chipBackground: const Color(0xFFDBEAFE),
          cardGradientColors: const [Color(0xFFFFFFFF), Color(0xFFDBEAFE)],
          heroGradientColors: const [Color(0xFF1E40AF), Color(0xFF1E3A8A)],
          cardShadow: _defaultLightCardShadow(),
          elevatedShadow: _elevatedShadow(const Color(0xFF1E40AF), 0.3),
        );
    }
  }

  ThemeColors get dark {
    switch (this) {
      case AppColorScheme.rose:
        // background/headerBackground/sidebarBackground/cardBorder below are
        // sourced 1:1 from financialite's dark-mode CSS variables
        // (--theme-bgPageDark/--theme-bgTopbarDark/--theme-bgSidebarDark/
        // --theme-borderDark).
        return _buildDarkTheme(
          primary: const Color(0xFFFB7185),
          primaryLight: const Color(0xFFFDA4AF),
          primaryDark: const Color(0xFFE11D48),
          secondary: const Color(0xFFF43F5E),
          accent: const Color(0xFFF43F5E),
          background: const Color(0xFF0A0404),
          surface: const Color(0xFF150707),
          surfaceVariant: const Color(0xFF1F0A0A),
          chipBackground: const Color(0x33F43F5E),
          divider: const Color(0x80450A0A),
          cardBorder: const Color(0x80450A0A),
          cardGradientColors: const [Color(0xFF1F0A0A), Color(0xFF150707)],
          heroGradientColors: const [Color(0xFFBE123C), Color(0xFF0A0404)],
          cardShadow: _cardShadow(Colors.black, 0.25),
          elevatedShadow: _elevatedShadow(const Color(0xFFFB7185), 0.2),
        );
      case AppColorScheme.forest:
        return _buildDarkTheme(
          primary: const Color(0xFF34D399),
          primaryLight: const Color(0xFF6EE7B7),
          primaryDark: const Color(0xFF059669),
          secondary: const Color(0xFF10B981),
          accent: const Color(0xFF2DD4BF),
          background: const Color(0xFF021008),
          surface: const Color(0xFF0C1F14),
          surfaceVariant: const Color(0xFF12291B),
          chipBackground: const Color(0x2622C55E),
          divider: const Color(0x8014532D),
          cardGradientColors: const [Color(0xFF12291B), Color(0xFF0C1F14)],
          heroGradientColors: const [Color(0xFF059669), Color(0xFF021008)],
          cardShadow: _cardShadow(Colors.black, 0.25),
          elevatedShadow: _elevatedShadow(const Color(0xFF34D399), 0.2),
        );
      case AppColorScheme.black:
        return _buildDarkTheme(
          primary: const Color(0xFFD1D5DB),
          primaryLight: const Color(0xFF9CA3AF),
          primaryDark: const Color(0xFFF9FAFB),
          secondary: const Color(0xFFE5E7EB),
          accent: const Color(0xFFFFFFFF),
          background: const Color(0xFF0A0A0A),
          surface: const Color(0xFF141414),
          surfaceVariant: const Color(0xFF1E1E1E),
          onSurface: const Color(0xFFF9FAFB),
          divider: const Color(0xFF2E2E2E),
          chipBackground: const Color(0xFF1E1E1E),
          primaryGradientColors: const [Color(0xFF374151), Color(0xFF1F2937)],
          cardGradientColors: const [Color(0xFF1E1E1E), Color(0xFF141414)],
          heroGradientColors: const [Color(0xFF1F2937), Color(0xFF0A0A0A)],
          cardShadow: _cardShadow(Colors.black, 0.4),
          elevatedShadow: _elevatedShadow(Colors.black, 0.3),
        );
      case AppColorScheme.gold:
        return _buildDarkTheme(
          primary: const Color(0xFFFCD34D),
          primaryLight: const Color(0xFFFDE68A),
          primaryDark: const Color(0xFFF59E0B),
          secondary: const Color(0xFFFBBF24),
          accent: const Color(0xFFD97706),
          background: const Color(0xFF0F0A02),
          surface: const Color(0xFF1A1A0A),
          surfaceVariant: const Color(0xFF22200A),
          onSurface: const Color(0xFFFEF9C3),
          onSurfaceVariant: const Color(0xFFFCD34D),
          hint: const Color(0xFF92400E),
          divider: const Color(0xFF2A2510),
          chipBackground: const Color(0xFF2A2000),
          cardGradientColors: const [Color(0xFF22200A), Color(0xFF1A1A0A)],
          heroGradientColors: const [Color(0xFFD97706), Color(0xFF0F0A02)],
          cardShadow: _cardShadow(Colors.black, 0.3),
          elevatedShadow: _elevatedShadow(const Color(0xFFFCD34D), 0.2),
        );
      case AppColorScheme.lavender:
        return _buildDarkTheme(
          primary: const Color(0xFFA78BFA),
          primaryLight: const Color(0xFFC4B5FD),
          primaryDark: const Color(0xFF7C3AED),
          secondary: const Color(0xFF8B5CF6),
          accent: const Color(0xFF9333EA),
          background: const Color(0xFF0D0416),
          surface: const Color(0xFF14102A),
          surfaceVariant: const Color(0xFF1E1840),
          onSurface: const Color(0xFFF5F3FF),
          onSurfaceVariant: const Color(0xFFC4B5FD),
          hint: const Color(0xFF7C6FAA),
          divider: const Color(0xFF2A2050),
          chipBackground: const Color(0xFF1A1040),
          cardGradientColors: const [Color(0xFF1E1840), Color(0xFF14102A)],
          heroGradientColors: const [Color(0xFF7C3AED), Color(0xFF0D0416)],
          cardShadow: _cardShadow(Colors.black, 0.3),
          elevatedShadow: _elevatedShadow(const Color(0xFFA78BFA), 0.25),
        );
      case AppColorScheme.midnight:
        return _buildDarkTheme(
          primary: const Color(0xFF60A5FA),
          primaryLight: const Color(0xFF93C5FD),
          primaryDark: const Color(0xFF3B82F6),
          secondary: const Color(0xFF3B82F6),
          accent: const Color(0xFF2563EB),
          background: const Color(0xFF050614),
          surface: const Color(0xFF0D1425),
          surfaceVariant: const Color(0xFF141D35),
          onSurface: const Color(0xFFEFF6FF),
          onSurfaceVariant: const Color(0xFF93C5FD),
          hint: const Color(0xFF3B568A),
          divider: const Color(0xFF1A2540),
          chipBackground: const Color(0xFF0D1835),
          cardGradientColors: const [Color(0xFF141D35), Color(0xFF0D1425)],
          heroGradientColors: const [Color(0xFF1E40AF), Color(0xFF050614)],
          cardShadow: _cardShadow(Colors.black, 0.4),
          elevatedShadow: _elevatedShadow(const Color(0xFF60A5FA), 0.2),
        );
    }
  }
}
