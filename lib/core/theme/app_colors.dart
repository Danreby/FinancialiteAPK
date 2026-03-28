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
      case AppColorScheme.black:
        return ThemeColors(
          primary: const Color(0xFF1F2937),
          primaryLight: const Color(0xFF6B7280),
          primaryDark: const Color(0xFF111827),
          secondary: const Color(0xFF374151),
          accent: const Color(0xFF4B5563),
          background: const Color(0xFFF8F9FE),
          surface: const Color(0xFFFFFFFF),
          surfaceVariant: const Color(0xFFF1F3F8),
          onSurface: const Color(0xFF111827),
          onSurfaceVariant: const Color(0xFF6B7280),
          error: const Color(0xFFEF4444),
          success: const Color(0xFF10B981),
          warning: const Color(0xFFF59E0B),
          info: const Color(0xFF3B82F6),
          hint: const Color(0xFF9CA3AF),
          divider: const Color(0xFFE5E7EB),
          inputFill: const Color(0xFFF3F4F6),
          chipBackground: const Color(0xFFF3F4F6),
          cardBorder: const Color(0xFFE5E7EB),
          income: const Color(0xFF10B981),
          expense: const Color(0xFFEF4444),
          shimmerBase: const Color(0xFFE5E7EB),
          shimmerHighlight: const Color(0xFFF9FAFB),
          primaryGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1F2937), Color(0xFF111827)],
          ),
          cardGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1F2937), Color(0xFF374151), Color(0xFF4B5563)],
          ),
          heroGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F2937), Color(0xFF111827), Color(0xFF030712)],
          ),
          cardShadow: [
            BoxShadow(
              color: const Color(0xFF111827).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          elevatedShadow: [
            BoxShadow(
              color: const Color(0xFF1F2937).withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        );
      case AppColorScheme.gold:
        return ThemeColors(
          primary: const Color(0xFFD97706),
          primaryLight: const Color(0xFFFCD34D),
          primaryDark: const Color(0xFFB45309),
          secondary: const Color(0xFFF59E0B),
          accent: const Color(0xFFEF8C00),
          background: const Color(0xFFFFFBEB),
          surface: const Color(0xFFFFFFFF),
          surfaceVariant: const Color(0xFFFFF8E1),
          onSurface: const Color(0xFF1A1D26),
          onSurfaceVariant: const Color(0xFF6B7280),
          error: const Color(0xFFEF4444),
          success: const Color(0xFF10B981),
          warning: const Color(0xFFF59E0B),
          info: const Color(0xFF3B82F6),
          hint: const Color(0xFF9CA3AF),
          divider: const Color(0xFFFDE68A),
          inputFill: const Color(0xFFFFF8E1),
          chipBackground: const Color(0xFFFEF9C3),
          cardBorder: const Color(0xFFFDE68A),
          income: const Color(0xFF10B981),
          expense: const Color(0xFFEF4444),
          shimmerBase: const Color(0xFFFDE68A),
          shimmerHighlight: const Color(0xFFFFFBEB),
          primaryGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD97706), Color(0xFFB45309)],
          ),
          cardGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD97706), Color(0xFFF59E0B), Color(0xFFFCD34D)],
          ),
          heroGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD97706), Color(0xFFB45309), Color(0xFF92400E)],
          ),
          cardShadow: [
            BoxShadow(
              color: const Color(0xFFD97706).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          elevatedShadow: [
            BoxShadow(
              color: const Color(0xFFD97706).withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        );
      case AppColorScheme.lavender:
        return ThemeColors(
          primary: const Color(0xFF7C3AED),
          primaryLight: const Color(0xFFC4B5FD),
          primaryDark: const Color(0xFF6D28D9),
          secondary: const Color(0xFF8B5CF6),
          accent: const Color(0xFF9333EA),
          background: const Color(0xFFFAF5FF),
          surface: const Color(0xFFFFFFFF),
          surfaceVariant: const Color(0xFFF5F3FF),
          onSurface: const Color(0xFF1A1D26),
          onSurfaceVariant: const Color(0xFF6B7280),
          error: const Color(0xFFEF4444),
          success: const Color(0xFF10B981),
          warning: const Color(0xFFF59E0B),
          info: const Color(0xFF3B82F6),
          hint: const Color(0xFF9CA3AF),
          divider: const Color(0xFFE9D5FF),
          inputFill: const Color(0xFFF5F3FF),
          chipBackground: const Color(0xFFEDE9FE),
          cardBorder: const Color(0xFFE9D5FF),
          income: const Color(0xFF10B981),
          expense: const Color(0xFFEF4444),
          shimmerBase: const Color(0xFFE9D5FF),
          shimmerHighlight: const Color(0xFFFAF5FF),
          primaryGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
          ),
          cardGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6), Color(0xFFA78BFA)],
          ),
          heroGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7C3AED), Color(0xFF6D28D9), Color(0xFF4C1D95)],
          ),
          cardShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          elevatedShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        );
      case AppColorScheme.midnight:
        return ThemeColors(
          primary: const Color(0xFF1E40AF),
          primaryLight: const Color(0xFF93C5FD),
          primaryDark: const Color(0xFF1E3A8A),
          secondary: const Color(0xFF3B82F6),
          accent: const Color(0xFF2563EB),
          background: const Color(0xFFF0F4FF),
          surface: const Color(0xFFFFFFFF),
          surfaceVariant: const Color(0xFFEEF2FF),
          onSurface: const Color(0xFF1A1D26),
          onSurfaceVariant: const Color(0xFF6B7280),
          error: const Color(0xFFEF4444),
          success: const Color(0xFF10B981),
          warning: const Color(0xFFF59E0B),
          info: const Color(0xFF3B82F6),
          hint: const Color(0xFF9CA3AF),
          divider: const Color(0xFFBFDBFE),
          inputFill: const Color(0xFFEFF6FF),
          chipBackground: const Color(0xFFDBEAFE),
          cardBorder: const Color(0xFFBFDBFE),
          income: const Color(0xFF10B981),
          expense: const Color(0xFFEF4444),
          shimmerBase: const Color(0xFFBFDBFE),
          shimmerHighlight: const Color(0xFFEFF6FF),
          primaryGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E40AF), Color(0xFF1E3A8A)],
          ),
          cardGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF3B82F6)],
          ),
          heroGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E40AF), Color(0xFF1E3A8A), Color(0xFF172554)],
          ),
          cardShadow: [
            BoxShadow(
              color: const Color(0xFF1E40AF).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          elevatedShadow: [
            BoxShadow(
              color: const Color(0xFF1E40AF).withValues(alpha: 0.3),
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
      case AppColorScheme.black:
        return ThemeColors(
          primary: const Color(0xFFD1D5DB),
          primaryLight: const Color(0xFF9CA3AF),
          primaryDark: const Color(0xFFF9FAFB),
          secondary: const Color(0xFFE5E7EB),
          accent: const Color(0xFFFFFFFF),
          background: const Color(0xFF0A0A0A),
          surface: const Color(0xFF141414),
          surfaceVariant: const Color(0xFF1E1E1E),
          onSurface: const Color(0xFFF9FAFB),
          onSurfaceVariant: const Color(0xFF9CA3AF),
          error: const Color(0xFFF87171),
          success: const Color(0xFF34D399),
          warning: const Color(0xFFFBBF24),
          info: const Color(0xFF60A5FA),
          hint: const Color(0xFF6B7280),
          divider: const Color(0xFF2E2E2E),
          inputFill: const Color(0xFF1E1E1E),
          chipBackground: const Color(0xFF1E1E1E),
          cardBorder: const Color(0xFF2E2E2E),
          income: const Color(0xFF34D399),
          expense: const Color(0xFFF87171),
          shimmerBase: const Color(0xFF1E1E1E),
          shimmerHighlight: const Color(0xFF2E2E2E),
          primaryGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF374151), Color(0xFF1F2937)],
          ),
          cardGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1F2937), Color(0xFF141414), Color(0xFF0A0A0A)],
          ),
          heroGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F2937), Color(0xFF111827), Color(0xFF0A0A0A)],
          ),
          cardShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          elevatedShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        );
      case AppColorScheme.gold:
        return ThemeColors(
          primary: const Color(0xFFFCD34D),
          primaryLight: const Color(0xFFFDE68A),
          primaryDark: const Color(0xFFF59E0B),
          secondary: const Color(0xFFFBBF24),
          accent: const Color(0xFFD97706),
          background: const Color(0xFF0F1119),
          surface: const Color(0xFF1A1A0A),
          surfaceVariant: const Color(0xFF22200A),
          onSurface: const Color(0xFFFEF9C3),
          onSurfaceVariant: const Color(0xFFFCD34D),
          error: const Color(0xFFF87171),
          success: const Color(0xFF34D399),
          warning: const Color(0xFFFBBF24),
          info: const Color(0xFF60A5FA),
          hint: const Color(0xFF92400E),
          divider: const Color(0xFF2A2510),
          inputFill: const Color(0xFF22200A),
          chipBackground: const Color(0xFF2A2000),
          cardBorder: const Color(0xFF2A2510),
          income: const Color(0xFF34D399),
          expense: const Color(0xFFF87171),
          shimmerBase: const Color(0xFF22200A),
          shimmerHighlight: const Color(0xFF2A2510),
          primaryGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
          ),
          cardGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2000), Color(0xFF1A1800), Color(0xFF0F1119)],
          ),
          heroGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A2000), Color(0xFF1A1500), Color(0xFF0F1119)],
          ),
          cardShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          elevatedShadow: [
            BoxShadow(
              color: const Color(0xFFFCD34D).withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        );
      case AppColorScheme.lavender:
        return ThemeColors(
          primary: const Color(0xFFA78BFA),
          primaryLight: const Color(0xFFC4B5FD),
          primaryDark: const Color(0xFF7C3AED),
          secondary: const Color(0xFF8B5CF6),
          accent: const Color(0xFF9333EA),
          background: const Color(0xFF0F1119),
          surface: const Color(0xFF14102A),
          surfaceVariant: const Color(0xFF1E1840),
          onSurface: const Color(0xFFF5F3FF),
          onSurfaceVariant: const Color(0xFFC4B5FD),
          error: const Color(0xFFF87171),
          success: const Color(0xFF34D399),
          warning: const Color(0xFFFBBF24),
          info: const Color(0xFF60A5FA),
          hint: const Color(0xFF7C6FAA),
          divider: const Color(0xFF2A2050),
          inputFill: const Color(0xFF1E1840),
          chipBackground: const Color(0xFF1A1040),
          cardBorder: const Color(0xFF2A2050),
          income: const Color(0xFF34D399),
          expense: const Color(0xFFF87171),
          shimmerBase: const Color(0xFF1E1840),
          shimmerHighlight: const Color(0xFF2A2050),
          primaryGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
          ),
          cardGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1040), Color(0xFF14102A), Color(0xFF0F1119)],
          ),
          heroGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1040), Color(0xFF100C29), Color(0xFF0F1119)],
          ),
          cardShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          elevatedShadow: [
            BoxShadow(
              color: const Color(0xFFA78BFA).withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        );
      case AppColorScheme.midnight:
        return ThemeColors(
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
          error: const Color(0xFFF87171),
          success: const Color(0xFF34D399),
          warning: const Color(0xFFFBBF24),
          info: const Color(0xFF60A5FA),
          hint: const Color(0xFF3B568A),
          divider: const Color(0xFF1A2540),
          inputFill: const Color(0xFF141D35),
          chipBackground: const Color(0xFF0D1835),
          cardBorder: const Color(0xFF1A2540),
          income: const Color(0xFF34D399),
          expense: const Color(0xFFF87171),
          shimmerBase: const Color(0xFF141D35),
          shimmerHighlight: const Color(0xFF1A2540),
          primaryGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
          ),
          cardGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1835), Color(0xFF0D1425), Color(0xFF060A18)],
          ),
          heroGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1835), Color(0xFF08102A), Color(0xFF060A18)],
          ),
          cardShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          elevatedShadow: [
            BoxShadow(
              color: const Color(0xFF60A5FA).withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        );
    }
  }
}
