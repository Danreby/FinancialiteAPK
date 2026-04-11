import 'package:flutter/material.dart';

enum AppColorScheme { rose, forest, black, gold, lavender, midnight }

class ThemeColors {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;
  final Color accent;
  final Color background;
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
// Helper builders – keep common light / dark values in one place
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
  Color background = const Color(0xFFF8F9FE),
  Color surfaceVariant = const Color(0xFFF1F3F8),
  Color onSurface = const Color(0xFF1A1D26),
  Color divider = const Color(0xFFE5E7EB),
  Color inputFill = const Color(0xFFF3F4F6),
  Color cardBorder = const Color(0xFFF3F4F6),
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
    surface: const Color(0xFFFFFFFF),
    surfaceVariant: surfaceVariant,
    onSurface: onSurface,
    onSurfaceVariant: const Color(0xFF6B7280),
    error: const Color(0xFFEF4444),
    success: const Color(0xFF10B981),
    warning: const Color(0xFFF59E0B),
    info: const Color(0xFF3B82F6),
    hint: const Color(0xFF9CA3AF),
    divider: divider,
    inputFill: inputFill,
    chipBackground: chipBackground,
    cardBorder: cardBorder,
    income: const Color(0xFF10B981),
    expense: const Color(0xFFEF4444),
    shimmerBase: shimmerBase,
    shimmerHighlight: shimmerHighlight,
    primaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primary, primaryDark],
    ),
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: cardGradientColors,
    ),
    heroGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
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
  required Color chipBackground,
  required List<Color> cardGradientColors,
  required List<Color> heroGradientColors,
  required List<BoxShadow> cardShadow,
  required List<BoxShadow> elevatedShadow,
  List<Color>? primaryGradientColors,
  Color background = const Color(0xFF0F1119),
  Color surface = const Color(0xFF1A1D2E),
  Color surfaceVariant = const Color(0xFF222640),
  Color onSurface = const Color(0xFFF3F4F6),
  Color onSurfaceVariant = const Color(0xFF9CA3AF),
  Color hint = const Color(0xFF6B7280),
  Color divider = const Color(0xFF2A2D42),
  Color inputFill = const Color(0xFF222640),
  Color cardBorder = const Color(0xFF2A2D42),
  Color shimmerBase = const Color(0xFF222640),
  Color shimmerHighlight = const Color(0xFF2A2D42),
}) {
  return ThemeColors(
    primary: primary,
    primaryLight: primaryLight,
    primaryDark: primaryDark,
    secondary: secondary,
    accent: accent,
    background: background,
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
    inputFill: inputFill,
    chipBackground: chipBackground,
    cardBorder: cardBorder,
    income: const Color(0xFF34D399),
    expense: const Color(0xFFF87171),
    shimmerBase: shimmerBase,
    shimmerHighlight: shimmerHighlight,
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
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: heroGradientColors,
    ),
    cardShadow: cardShadow,
    elevatedShadow: elevatedShadow,
  );
}

// ---------------------------------------------------------------------------
// Reusable shadow presets
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
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];

// ---------------------------------------------------------------------------
// Extension – light & dark getters
// ---------------------------------------------------------------------------

extension AppColorSchemeExtension on AppColorScheme {
  ThemeColors get light {
    switch (this) {
      case AppColorScheme.rose:
        return _buildLightTheme(
          primary: const Color(0xFFE11D48),
          primaryLight: const Color(0xFFFDA4AF),
          primaryDark: const Color(0xFFBE123C),
          secondary: const Color(0xFFFB7185),
          accent: const Color(0xFFFF6B9D),
          chipBackground: const Color(0xFFFFF1F2),
          cardGradientColors: const [
            Color(0xFFE11D48),
            Color(0xFFF43F5E),
            Color(0xFFFB7185)
          ],
          heroGradientColors: const [
            Color(0xFFE11D48),
            Color(0xFFBE123C),
            Color(0xFF9F1239)
          ],
          cardShadow: _defaultLightCardShadow(),
          elevatedShadow: _elevatedShadow(const Color(0xFFE11D48), 0.3),
        );
      case AppColorScheme.forest:
        return _buildLightTheme(
          primary: const Color(0xFF059669),
          primaryLight: const Color(0xFF6EE7B7),
          primaryDark: const Color(0xFF047857),
          secondary: const Color(0xFF34D399),
          accent: const Color(0xFF2DD4BF),
          chipBackground: const Color(0xFFECFDF5),
          cardGradientColors: const [
            Color(0xFF059669),
            Color(0xFF10B981),
            Color(0xFF34D399)
          ],
          heroGradientColors: const [
            Color(0xFF059669),
            Color(0xFF047857),
            Color(0xFF065F46)
          ],
          cardShadow: _defaultLightCardShadow(),
          elevatedShadow: _elevatedShadow(const Color(0xFF059669), 0.3),
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
          cardBorder: const Color(0xFFE5E7EB),
          cardGradientColors: const [
            Color(0xFF1F2937),
            Color(0xFF374151),
            Color(0xFF4B5563)
          ],
          heroGradientColors: const [
            Color(0xFF1F2937),
            Color(0xFF111827),
            Color(0xFF030712)
          ],
          cardShadow: _cardShadow(const Color(0xFF111827), 0.08),
          elevatedShadow: _elevatedShadow(const Color(0xFF1F2937), 0.4),
        );
      case AppColorScheme.gold:
        return _buildLightTheme(
          primary: const Color(0xFFD97706),
          primaryLight: const Color(0xFFFCD34D),
          primaryDark: const Color(0xFFB45309),
          secondary: const Color(0xFFF59E0B),
          accent: const Color(0xFFEF8C00),
          background: const Color(0xFFFFFBEB),
          surfaceVariant: const Color(0xFFFFF8E1),
          chipBackground: const Color(0xFFFEF9C3),
          divider: const Color(0xFFFDE68A),
          inputFill: const Color(0xFFFFF8E1),
          cardBorder: const Color(0xFFFDE68A),
          shimmerBase: const Color(0xFFFDE68A),
          shimmerHighlight: const Color(0xFFFFFBEB),
          cardGradientColors: const [
            Color(0xFFD97706),
            Color(0xFFF59E0B),
            Color(0xFFFCD34D)
          ],
          heroGradientColors: const [
            Color(0xFFD97706),
            Color(0xFFB45309),
            Color(0xFF92400E)
          ],
          cardShadow: _cardShadow(const Color(0xFFD97706), 0.08),
          elevatedShadow: _elevatedShadow(const Color(0xFFD97706), 0.35),
        );
      case AppColorScheme.lavender:
        return _buildLightTheme(
          primary: const Color(0xFF7C3AED),
          primaryLight: const Color(0xFFC4B5FD),
          primaryDark: const Color(0xFF6D28D9),
          secondary: const Color(0xFF8B5CF6),
          accent: const Color(0xFF9333EA),
          background: const Color(0xFFFAF5FF),
          surfaceVariant: const Color(0xFFF5F3FF),
          chipBackground: const Color(0xFFEDE9FE),
          divider: const Color(0xFFE9D5FF),
          inputFill: const Color(0xFFF5F3FF),
          cardBorder: const Color(0xFFE9D5FF),
          shimmerBase: const Color(0xFFE9D5FF),
          shimmerHighlight: const Color(0xFFFAF5FF),
          cardGradientColors: const [
            Color(0xFF7C3AED),
            Color(0xFF8B5CF6),
            Color(0xFFA78BFA)
          ],
          heroGradientColors: const [
            Color(0xFF7C3AED),
            Color(0xFF6D28D9),
            Color(0xFF4C1D95)
          ],
          cardShadow: _cardShadow(const Color(0xFF7C3AED), 0.06),
          elevatedShadow: _elevatedShadow(const Color(0xFF7C3AED), 0.3),
        );
      case AppColorScheme.midnight:
        return _buildLightTheme(
          primary: const Color(0xFF1E40AF),
          primaryLight: const Color(0xFF93C5FD),
          primaryDark: const Color(0xFF1E3A8A),
          secondary: const Color(0xFF3B82F6),
          accent: const Color(0xFF2563EB),
          background: const Color(0xFFF0F4FF),
          surfaceVariant: const Color(0xFFEEF2FF),
          chipBackground: const Color(0xFFDBEAFE),
          divider: const Color(0xFFBFDBFE),
          inputFill: const Color(0xFFEFF6FF),
          cardBorder: const Color(0xFFBFDBFE),
          shimmerBase: const Color(0xFFBFDBFE),
          shimmerHighlight: const Color(0xFFEFF6FF),
          cardGradientColors: const [
            Color(0xFF1E40AF),
            Color(0xFF2563EB),
            Color(0xFF3B82F6)
          ],
          heroGradientColors: const [
            Color(0xFF1E40AF),
            Color(0xFF1E3A8A),
            Color(0xFF172554)
          ],
          cardShadow: _cardShadow(const Color(0xFF1E40AF), 0.06),
          elevatedShadow: _elevatedShadow(const Color(0xFF1E40AF), 0.3),
        );
    }
  }

  ThemeColors get dark {
    switch (this) {
      case AppColorScheme.rose:
        return _buildDarkTheme(
          primary: const Color(0xFFFB7185),
          primaryLight: const Color(0xFFFDA4AF),
          primaryDark: const Color(0xFFE11D48),
          secondary: const Color(0xFFF43F5E),
          accent: const Color(0xFFFF6B9D),
          chipBackground: const Color(0xFF2A1520),
          cardGradientColors: const [
            Color(0xFF2A1528),
            Color(0xFF1E1A35),
            Color(0xFF1A1D2E)
          ],
          heroGradientColors: const [
            Color(0xFF2A1528),
            Color(0xFF1A0F20),
            Color(0xFF0F1119)
          ],
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
          chipBackground: const Color(0xFF0A2520),
          cardGradientColors: const [
            Color(0xFF0A2520),
            Color(0xFF152028),
            Color(0xFF1A1D2E)
          ],
          heroGradientColors: const [
            Color(0xFF0A2520),
            Color(0xFF0F1A1E),
            Color(0xFF0F1119)
          ],
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
          inputFill: const Color(0xFF1E1E1E),
          chipBackground: const Color(0xFF1E1E1E),
          cardBorder: const Color(0xFF2E2E2E),
          shimmerBase: const Color(0xFF1E1E1E),
          shimmerHighlight: const Color(0xFF2E2E2E),
          primaryGradientColors: const [Color(0xFF374151), Color(0xFF1F2937)],
          cardGradientColors: const [
            Color(0xFF1F2937),
            Color(0xFF141414),
            Color(0xFF0A0A0A)
          ],
          heroGradientColors: const [
            Color(0xFF1F2937),
            Color(0xFF111827),
            Color(0xFF0A0A0A)
          ],
          cardShadow: _cardShadow(Colors.black, 0.5),
          elevatedShadow: _elevatedShadow(Colors.black, 0.4),
        );
      case AppColorScheme.gold:
        return _buildDarkTheme(
          primary: const Color(0xFFFCD34D),
          primaryLight: const Color(0xFFFDE68A),
          primaryDark: const Color(0xFFF59E0B),
          secondary: const Color(0xFFFBBF24),
          accent: const Color(0xFFD97706),
          surface: const Color(0xFF1A1A0A),
          surfaceVariant: const Color(0xFF22200A),
          onSurface: const Color(0xFFFEF9C3),
          onSurfaceVariant: const Color(0xFFFCD34D),
          hint: const Color(0xFF92400E),
          divider: const Color(0xFF2A2510),
          inputFill: const Color(0xFF22200A),
          chipBackground: const Color(0xFF2A2000),
          cardBorder: const Color(0xFF2A2510),
          shimmerBase: const Color(0xFF22200A),
          shimmerHighlight: const Color(0xFF2A2510),
          cardGradientColors: const [
            Color(0xFF2A2000),
            Color(0xFF1A1800),
            Color(0xFF0F1119)
          ],
          heroGradientColors: const [
            Color(0xFF2A2000),
            Color(0xFF1A1500),
            Color(0xFF0F1119)
          ],
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
          surface: const Color(0xFF14102A),
          surfaceVariant: const Color(0xFF1E1840),
          onSurface: const Color(0xFFF5F3FF),
          onSurfaceVariant: const Color(0xFFC4B5FD),
          hint: const Color(0xFF7C6FAA),
          divider: const Color(0xFF2A2050),
          inputFill: const Color(0xFF1E1840),
          chipBackground: const Color(0xFF1A1040),
          cardBorder: const Color(0xFF2A2050),
          shimmerBase: const Color(0xFF1E1840),
          shimmerHighlight: const Color(0xFF2A2050),
          cardGradientColors: const [
            Color(0xFF1A1040),
            Color(0xFF14102A),
            Color(0xFF0F1119)
          ],
          heroGradientColors: const [
            Color(0xFF1A1040),
            Color(0xFF100C29),
            Color(0xFF0F1119)
          ],
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
          background: const Color(0xFF060A18),
          surface: const Color(0xFF0D1425),
          surfaceVariant: const Color(0xFF141D35),
          onSurface: const Color(0xFFEFF6FF),
          onSurfaceVariant: const Color(0xFF93C5FD),
          hint: const Color(0xFF3B568A),
          divider: const Color(0xFF1A2540),
          inputFill: const Color(0xFF141D35),
          chipBackground: const Color(0xFF0D1835),
          cardBorder: const Color(0xFF1A2540),
          shimmerBase: const Color(0xFF141D35),
          shimmerHighlight: const Color(0xFF1A2540),
          cardGradientColors: const [
            Color(0xFF0D1835),
            Color(0xFF0D1425),
            Color(0xFF060A18)
          ],
          heroGradientColors: const [
            Color(0xFF0D1835),
            Color(0xFF08102A),
            Color(0xFF060A18)
          ],
          cardShadow: _cardShadow(Colors.black, 0.4),
          elevatedShadow: _elevatedShadow(const Color(0xFF60A5FA), 0.2),
        );
    }
  }
}
