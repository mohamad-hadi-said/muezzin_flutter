import 'package:flutter/material.dart';
import 'package:muezzin_flutter/core/theme/app_text_theme.dart';

class MuezzinTheme {
  // Colors - Updated based on the uploaded design
  static const Color primaryColor = Color(0xFF5B9BD5); // Blue from the button
  static const Color secondaryColor = Color(0xFF4A90E2); // Lighter blue variant
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light gray background
  static const Color cardColor = Color(0xFFFFFFFF); // White cards
  static const Color primaryBackground = Color(0xFFF8F8F8); // Very light background
  static const Color secondaryBackground = Color(0xFFEFEFEF); // Light gray variant
  static const Color accentColor = Color(0xFF5B9BD5); // Same as primary
  static const Color goldColor = Color(0xFFD4AF37); // Subtle gold
  static const Color textPrimary = Color(0xFF2C3E50); // Dark text for readability
  static const Color textSecondary = Color(0xFF7F8C8D); // Gray text
  static const Color disabledColor = Color(0xFFBDC3C7); // Light gray for disabled
  static const Color errorColor = Color(0xFFE74C3C); // Soft red
  static const Color successColor = Color(0xFF27AE60); // Soft green
  static const Color outlineColor = Color(0xFFE0E0E0); // Light border

  
  // Theme Data - Merged from both themes
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Cairo',
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: cardColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textPrimary,
        onSurface: textPrimary,
        outline: outlineColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textTheme: AppTextTheme.lightTextTheme,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      fontFamily: 'Cairo',
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        background: Color(0xFF1A1A1A),
        surface: Color(0xFF2D2D2D),
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.white,
        onSurface: Colors.white,
        outline: Color(0xFF404040),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textTheme: AppTextTheme.darkTextTheme,
      cardTheme: CardThemeData(
        color: const Color(0xFF2D2D2D),
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}