import 'package:flutter/material.dart';

class AppColors {
  static const Color green = Color(0xFF2E7D32);
  static const Color greenDark = Color(0xFF1B5E20);
  static const Color black = Color(0xFF111111);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFE0E0E0);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.green,
    onPrimary: AppColors.white,
    secondary: AppColors.greenDark,
    onSecondary: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.black,
    error: Colors.red.shade700,
    onError: AppColors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.black,
        side: const BorderSide(color: AppColors.black, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.grey),
      ),
    ),
  );
}
