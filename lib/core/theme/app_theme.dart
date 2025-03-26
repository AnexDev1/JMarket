import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'text_styles.dart';

class AppTheme {
  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlack,
        onPrimary: AppColors.primaryWhite,
        secondary: AppColors.gray800,
        onSecondary: AppColors.primaryWhite,
        surface: AppColors.primaryWhite,
        onSurface: AppColors.primaryBlack,
        background: AppColors.primaryWhite,
        onBackground: AppColors.primaryBlack,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.primaryWhite,
      textTheme: TextStyles.textTheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.primaryWhite,
        foregroundColor: AppColors.primaryBlack,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: AppColors.gray200,
        labelTextStyle: WidgetStateProperty.all(
          TextStyles.caption.copyWith(color: AppColors.primaryBlack),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlack,
          foregroundColor: AppColors.primaryWhite,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyles.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      useMaterial3: true,
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryWhite,
        onPrimary: AppColors.primaryBlack,
        secondary: AppColors.gray200,
        onSecondary: AppColors.primaryBlack,
        surface: AppColors.gray900,
        onSurface: AppColors.primaryWhite,
        background: AppColors.primaryBlack,
        onBackground: AppColors.primaryWhite,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.primaryBlack,
      textTheme: TextStyles.textTheme.apply(
        bodyColor: AppColors.primaryWhite,
        displayColor: AppColors.primaryWhite,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.primaryWhite,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.gray900,
        indicatorColor: AppColors.gray800,
        labelTextStyle: MaterialStateProperty.all(
          TextStyles.caption.copyWith(color: AppColors.primaryWhite),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryWhite,
          foregroundColor: AppColors.primaryBlack,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyles.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      useMaterial3: true,
    );
  }
}
