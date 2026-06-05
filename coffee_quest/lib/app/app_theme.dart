import 'package:coffee_quest/shared/theme/app_colors.dart';
import 'package:coffee_quest/shared/theme/app_typography.dart';
import 'package:flutter/material.dart';

abstract class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkRoastBg,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkRoastAccent,
      onPrimary: AppColors.darkRoastAccentInk,
      secondary: AppColors.darkRoastSage,
      onSecondary: AppColors.darkRoastBg,
      error: AppColors.darkRoastBerry,
      onError: AppColors.darkRoastAccentInk,
      surface: AppColors.darkRoastSurface,
      onSurface: AppColors.darkRoastInk,
      surfaceContainerHighest: AppColors.darkRoastSurface2,
      onSurfaceVariant: AppColors.darkRoastInkMute,
      outline: AppColors.darkRoastRule,
    ),
    textTheme: AppTypography.textTheme(),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.darkRoastBg,
      foregroundColor: AppColors.darkRoastInk,
    ),
  );
}
