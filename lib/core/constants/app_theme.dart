import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Light theme data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.gold,
        secondary: AppColors.purple,
        surface: AppColors.background,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkPurple,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppColors.gold,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: AppColors.gold,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: AppColors.white,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.lightGrey,
          fontSize: 14,
        ),
        labelSmall: TextStyle(
          color: AppColors.lightGrey,
          fontSize: 12,
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.gold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.darkPurple,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: AppColors.gold,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: const BorderSide(color: AppColors.gold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.lightGrey),
        hintStyle: const TextStyle(color: AppColors.darkGrey),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: AppColors.gold.withValues(alpha: 0.3),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.gold,
        size: 24,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.darkPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkPurple,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.lightGrey,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightPurple,
        thickness: 1,
      ),
    );
  }

  // Dark theme data (more mystical)
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.purple,
        surface: AppColors.cardBackground,
        error: AppColors.error,
      ),
    );
  }

  // Typography
  static TextStyle get headingLarge {
    return const TextStyle(
      color: AppColors.gold,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle get headingMedium {
    return const TextStyle(
      color: AppColors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle get headingSmall {
    return const TextStyle(
      color: AppColors.gold,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle get bodyLarge {
    return const TextStyle(
      color: AppColors.white,
      fontSize: 16,
    );
  }

  static TextStyle get bodyMedium {
    return const TextStyle(
      color: AppColors.lightGrey,
      fontSize: 14,
    );
  }

  static TextStyle get bodySmall {
    return const TextStyle(
      color: AppColors.darkGrey,
      fontSize: 12,
    );
  }

  static TextStyle get labelLarge {
    return const TextStyle(
      color: AppColors.gold,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
  }

  // Border Radius
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusMedium = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusXLarge = BorderRadius.all(Radius.circular(24));

  // Padding and Margins
  static const EdgeInsets paddingSmall = EdgeInsets.all(8);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16);
  static const EdgeInsets paddingLarge = EdgeInsets.all(24);
  static const EdgeInsets paddingXLarge = EdgeInsets.all(32);

  // Spacing
  static const double spacingXSmall = 4;
  static const double spacingSmall = 8;
  static const double spacingMedium = 12;
  static const double spacingLarge = 16;
  static const double spacingXLarge = 24;
  static const double spacingXXLarge = 32;
}
