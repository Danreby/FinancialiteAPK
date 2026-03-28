part of 'theme_cubit.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final String colorSchemeName;

  const ThemeState({
    this.themeMode = ThemeMode.light,
    this.colorSchemeName = 'rose',
  });

  AppColorScheme get colorScheme {
    switch (colorSchemeName) {
      case 'forest':
        return AppColorScheme.forest;
      case 'black':
        return AppColorScheme.black;
      case 'gold':
        return AppColorScheme.gold;
      case 'lavender':
        return AppColorScheme.lavender;
      case 'midnight':
        return AppColorScheme.midnight;
      case 'rose':
      default:
        return AppColorScheme.rose;
    }
  }

  ThemeColors get colors {
    return themeMode == ThemeMode.dark ? colorScheme.dark : colorScheme.light;
  }

  bool get isDark => themeMode == ThemeMode.dark;

  ThemeState copyWith({ThemeMode? themeMode, String? colorSchemeName}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      colorSchemeName: colorSchemeName ?? this.colorSchemeName,
    );
  }

  @override
  List<Object?> get props => [themeMode, colorSchemeName];
}
