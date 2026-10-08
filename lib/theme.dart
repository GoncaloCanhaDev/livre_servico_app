import 'package:flutter/material.dart';

class AppColors {
  static const Color green = Color(0xFF2E7D32);
  static const Color greenDark = Color(0xFF1B5E20);
  static const Color black = Color(0xFF111111);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFE0E0E0);
}

/// The light or dark theme. Both keep the black app bar; the dark one uses
/// lighter greens so they read on a dark background.
ThemeData buildAppTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final surface = dark ? const Color(0xFF121212) : AppColors.white;
  final onSurface = dark ? const Color(0xFFE6E6E6) : AppColors.black;
  final cardColor = dark ? const Color(0xFF1E1E1E) : AppColors.white;
  final border = dark ? const Color(0xFF3A3A3A) : AppColors.grey;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: dark ? Colors.green.shade600 : AppColors.green,
    onPrimary: AppColors.white,
    secondary: dark ? Colors.green.shade300 : AppColors.greenDark,
    onSecondary: dark ? AppColors.black : AppColors.white,
    surface: surface,
    onSurface: onSurface,
    // Left to their defaults in the light theme, as before dark mode.
    onSurfaceVariant: dark ? const Color(0xFFB0B0B0) : null,
    outline: dark ? const Color(0xFF5A5A5A) : null,
    outlineVariant: dark ? const Color(0xFF333333) : null,
    error: dark ? Colors.red.shade300 : Colors.red.shade700,
    onError: dark ? AppColors.black : AppColors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: onSurface,
        side: BorderSide(color: onSurface, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border),
      ),
    ),
  );
}

/// Theme colours for widgets, so they follow the light or dark theme.
extension AppThemeColors on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Secondary text and icons.
  Color get muted => isDark ? colors.onSurfaceVariant : Colors.black54;

  /// Faint text, hints and greyed-out items.
  Color get faint =>
      isDark ? colors.onSurface.withValues(alpha: 0.5) : Colors.black45;

  /// Fainter still: locked and disabled items.
  Color get faintest =>
      isDark ? colors.onSurface.withValues(alpha: 0.38) : Colors.black38;

  /// Thin lines and cell borders.
  Color get hairline => isDark ? colors.outlineVariant : Colors.black12;

  /// The fill of a greyed-out badge (white text on it).
  Color get greyedFill => isDark ? colors.outline : Colors.black26;

  /// A light background tinted with [color] (cells, warning cards): its
  /// [shade] in the light theme, a dim tint of it in the dark one.
  Color tint(MaterialColor color, [int shade = 50]) => isDark
      ? Color.alphaBlend(color.withValues(alpha: 0.22), colors.surface)
      : color[shade]!;

  /// Text on an orange [tint].
  Color get warningText =>
      isDark ? Colors.orange.shade200 : Colors.orange.shade900;
}
