import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const _keyThemeMode = 'theme_mode';
  static const _keyColorScheme = 'color_scheme';

  ThemeCubit() : super(const ThemeState()) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_keyThemeMode);
    final schemeName = prefs.getString(_keyColorScheme) ?? 'rose';
    ThemeMode mode;
    switch (modeStr) {
      case 'light':
        mode = ThemeMode.light;
        break;
      case 'system':
        mode = ThemeMode.system;
        break;
      default:
        // Dark is the app's designed default -- it's the mode the brand
        // (rose neumorphic accents, deep near-black surfaces) is actually
        // authored for, matching the auth flow. Light stays a real,
        // fully-supported opt-in via Settings, not the first impression.
        mode = ThemeMode.dark;
    }
    emit(ThemeState(themeMode: mode, colorSchemeName: schemeName));
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    String modeStr;
    switch (state.themeMode) {
      case ThemeMode.dark:
        modeStr = 'dark';
        break;
      case ThemeMode.system:
        modeStr = 'system';
        break;
      default:
        modeStr = 'light';
    }
    await prefs.setString(_keyThemeMode, modeStr);
    await prefs.setString(_keyColorScheme, state.colorSchemeName);
  }

  void toggleThemeMode() {
    final newMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(state.copyWith(themeMode: newMode));
    _save();
  }

  void setThemeMode(ThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
    _save();
  }

  void setColorScheme(String schemeName) {
    emit(state.copyWith(colorSchemeName: schemeName));
    _save();
  }
}
