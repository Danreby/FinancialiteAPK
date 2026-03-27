import 'package:flutter/material.dart';

enum AppColorScheme { rose, forest }

class ThemeColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color onSurface;
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

  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.onSurface,
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
  });
}

extension AppColorSchemeExtension on AppColorScheme {
  ThemeColors get light {
    switch (this) {
      case AppColorScheme.rose:
        return const ThemeColors(
          primary: Color(0xFFE11D48),
          secondary: Color(0xFFFB7185),
          background: Color(0xFFF8FAFC),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF0F172A),
          error: Color(0xFFDC2626),
          success: Color(0xFF16A34A),
          warning: Color(0xFFF59E0B),
          info: Color(0xFF3B82F6),
          hint: Color(0xFF94A3B8),
          divider: Color(0xFFE2E8F0),
          inputFill: Color(0xFFF1F5F9),
          chipBackground: Color(0xFFF1F5F9),
          cardBorder: Color(0xFFE2E8F0),
          income: Color(0xFF16A34A),
          expense: Color(0xFFDC2626),
        );
      case AppColorScheme.forest:
        return const ThemeColors(
          primary: Color(0xFF059669),
          secondary: Color(0xFF34D399),
          background: Color(0xFFF8FAFC),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF0F172A),
          error: Color(0xFFDC2626),
          success: Color(0xFF16A34A),
          warning: Color(0xFFF59E0B),
          info: Color(0xFF3B82F6),
          hint: Color(0xFF94A3B8),
          divider: Color(0xFFE2E8F0),
          inputFill: Color(0xFFF1F5F9),
          chipBackground: Color(0xFFF1F5F9),
          cardBorder: Color(0xFFE2E8F0),
          income: Color(0xFF16A34A),
          expense: Color(0xFFDC2626),
        );
    }
  }

  ThemeColors get dark {
    switch (this) {
      case AppColorScheme.rose:
        return const ThemeColors(
          primary: Color(0xFFFB7185),
          secondary: Color(0xFFE11D48),
          background: Color(0xFF0F172A),
          surface: Color(0xFF1E293B),
          onSurface: Color(0xFFF1F5F9),
          error: Color(0xFFF87171),
          success: Color(0xFF4ADE80),
          warning: Color(0xFFFBBF24),
          info: Color(0xFF60A5FA),
          hint: Color(0xFF64748B),
          divider: Color(0xFF334155),
          inputFill: Color(0xFF1E293B),
          chipBackground: Color(0xFF334155),
          cardBorder: Color(0xFF334155),
          income: Color(0xFF4ADE80),
          expense: Color(0xFFF87171),
        );
      case AppColorScheme.forest:
        return const ThemeColors(
          primary: Color(0xFF34D399),
          secondary: Color(0xFF059669),
          background: Color(0xFF0F172A),
          surface: Color(0xFF1E293B),
          onSurface: Color(0xFFF1F5F9),
          error: Color(0xFFF87171),
          success: Color(0xFF4ADE80),
          warning: Color(0xFFFBBF24),
          info: Color(0xFF60A5FA),
          hint: Color(0xFF64748B),
          divider: Color(0xFF334155),
          inputFill: Color(0xFF1E293B),
          chipBackground: Color(0xFF334155),
          cardBorder: Color(0xFF334155),
          income: Color(0xFF4ADE80),
          expense: Color(0xFFF87171),
        );
    }
  }
}
