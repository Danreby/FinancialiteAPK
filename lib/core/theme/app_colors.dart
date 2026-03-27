import 'package:flutter/material.dart';

enum AppColorScheme { rose, forest }

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
}

extension AppColorSchemeExtension on AppColorScheme {
  ThemeColors get light {
    switch (this) {
      case AppColorScheme.rose:
        return ThemeColors(
          primary: const Color(0xFFE11D48),
          primaryLight: const Color(0xFFFDA4AF),
          primaryDark: const Color(0xFFBE123C),
          secondary: const Color(0xFFFB7185),
          accent: const Color(0xFFFF6B9D),
          background: const Color(0xFFF8F9FE),
          surface: const Color(0xFFFFFFFF),
          surfaceVariant: const Color(0xFFF1F3F8),
          onSurface: const Color(0xFF1A1D26),
          onSurfaceVariant: const Color(0xFF6B7280),
          error: const Color(0xFFEF4444),
          success: const Color(0xFF10B981),
          warning: const Color(0xFFF59E0B),
          info: const Color(0xFF3B82F6),
          hint: const Color(0xFF9CA3AF),
          divider: const Color(0xFFE5E7EB),
          inputFill: const Color(0xFFF3F4F6),
          chipBackground: const Color(0xFFFFF1F2),
          cardBorder: const Color(0xFFF3F4F6),
          income: const Color(0xFF10B981),
          expense: const Color(0xFFEF4444),
          shimmerBase: const Color(0xFFE5E7EB),
          shimmerHighlight: const Color(0xFFF9FAFB),
          primaryGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
          ),
          cardGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE11D48), Color(0xFFF43F5E), Color(0xFFFB7185)],
          ),
          heroGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE11D48), Color(0xFFBE123C), Color(0xFF9F1239)],
          ),
          cardShadow: [
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
          ],
          elevatedShadow: [
            BoxShadow(
              color: const Color(0xFFE11D48).withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        );
      case AppColorScheme.forest:
        return ThemeColors(
          primary: const Color(0xFF059669),
          primaryLight: const Color(0xFF6EE7B7),
          primaryDark: const Color(0xFF047857),
          secondary: const Color(0xFF34D399),
          accent: const Color(0xFF2DD4BF),
          background: const Color(0xFFF8F9FE),
          surface: const Color(0xFFFFFFFF),
          surfaceVariant: const Color(0xFFF1F3F8),
          onSurface: const Color(0xFF1A1D26),
          onSurfaceVariant: const Color(0xFF6B7280),
          error: const Color(0xFFEF4444),
          success: const Color(0xFF10B981),
          warning: const Color(0xFFF59E0B),
          info: const Color(0xFF3B82F6),
          hint: const Color(0xFF9CA3AF),
          divider: const Color(0xFFE5E7EB),
          inputFill: const Color(0xFFF3F4F6),
          chipBackground: const Color(0xFFECFDF5),
          cardBorder: const Color(0xFFF3F4F6),
          income: const Color(0xFF10B981),
          expense: const Color(0xFFEF4444),
          shimmerBase: const Color(0xFFE5E7EB),
          shimmerHighlight: const Color(0xFFF9FAFB),
          primaryGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF059669), Color(0xFF047857)],
          ),
          cardGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
          ),
          heroGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF059669), Color(0xFF047857), Color(0xFF065F46)],
          ),
          cardShadow: [
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
          ],
          elevatedShadow: [
            BoxShadow(
              color: const Color(0xFF059669).withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        );
    }
  }

  ThemeColors get dark {
    switch (this) {
      case AppColorScheme.rose:
        return ThemeColors(
          primary: const Color(0xFFFB7185),
          primaryLight: const Color(0xFFFDA4AF),
          primaryDark: const Color(0xFFE11D48),
          secondary: const Color(0xFFF43F5E),
          accent: const Color(0xFFFF6B9D),
          background: const Color(0xFF0F1119),
          surface: const Color(0xFF1A1D2E),
          surfaceVariant: const Color(0xFF222640),
          onSurface: const Color(0xFFF3F4F6),
          onSurfaceVariant: const Color(0xFF9CA3AF),
          error: const Color(0xFFF87171),
          success: const Color(0xFF34D399),
          warning: const Color(0xFFFBBF24),
          info: const Color(0xFF60A5FA),
          hint: const Color(0xFF6B7280),
          divider: const Color(0xFF2A2D42),
          inputFill: const Color(0xFF222640),
          chipBackground: const Color(0xFF2A1520),
          cardBorder: const Color(0xFF2A2D42),
          income: const Color(0xFF34D399),
          expense: const Color(0xFFF87171),
          shimmerBase: const Color(0xFF222640),
          shimmerHighlight: const Color(0xFF2A2D42),
          primaryGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFB7185), Color(0xFFE11D48)],
          ),
          cardGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A1528), Color(0xFF1E1A35), Color(0xFF1A1D2E)],
          ),
          heroGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A1528), Color(0xFF1A0F20), Color(0xFF0F1119)],
          ),
          cardShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          elevatedShadow: [
            BoxShadow(
              color: const Color(0xFFFB7185).withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        );
      case AppColorScheme.forest:
        return ThemeColors(
          primary: const Color(0xFF34D399),
          primaryLight: const Color(0xFF6EE7B7),
          primaryDark: const Color(0xFF059669),
          secondary: const Color(0xFF10B981),
          accent: const Color(0xFF2DD4BF),
          background: const Color(0xFF0F1119),
          surface: const Color(0xFF1A1D2E),
          surfaceVariant: const Color(0xFF222640),
          onSurface: const Color(0xFFF3F4F6),
          onSurfaceVariant: const Color(0xFF9CA3AF),
          error: const Color(0xFFF87171),
          success: const Color(0xFF34D399),
          warning: const Color(0xFFFBBF24),
          info: const Color(0xFF60A5FA),
          hint: const Color(0xFF6B7280),
          divider: const Color(0xFF2A2D42),
          inputFill: const Color(0xFF222640),
          chipBackground: const Color(0xFF0A2520),
          cardBorder: const Color(0xFF2A2D42),
          income: const Color(0xFF34D399),
          expense: const Color(0xFFF87171),
          shimmerBase: const Color(0xFF222640),
          shimmerHighlight: const Color(0xFF2A2D42),
          primaryGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF34D399), Color(0xFF059669)],
          ),
          cardGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A2520), Color(0xFF152028), Color(0xFF1A1D2E)],
          ),
          heroGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A2520), Color(0xFF0F1A1E), Color(0xFF0F1119)],
          ),
          cardShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          elevatedShadow: [
            BoxShadow(
              color: const Color(0xFF34D399).withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        );
    }
  }
}
