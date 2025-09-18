import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF3F51B5);
  static const Color primaryDark = Color(0xFF303F9F);
  static const Color primaryLight = Color(0xFFC5CAE9);
  
  // Secondary colors
  static const Color secondary = Color(0xFFFF4081);
  static const Color secondaryDark = Color(0xFFC2185B);
  static const Color secondaryLight = Color(0xFFF8BBD0);
  
  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFE53935);
  
  // Text colors
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF212121);
  static const Color onError = Colors.white;
  
  // Additional colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
  static const Color disabled = Color(0xFFBDBDBD);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, Color(0xFFE57373)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
