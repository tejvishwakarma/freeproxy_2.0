import 'package:flutter/material.dart';

class AppColors {
  // Light theme
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03A9F4);
  static const Color accent = Color(0xFF00BCD4);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF212121);
  static const Color textMedium = Color(0xFF666666);
  static const Color textLight = Color(0xFFFFFFFF);

  // Dark theme
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color secondaryDark = Color(0xFF0288D1);
  static const Color accentDark = Color(0xFF0097A7);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
}

class ApiConstants {
  static const String baseUrl = 'https://your-backend-url.com/api';
}

class AppConstants {
  static const String appName = 'Free Proxy';
  static const String appVersion = '1.0.0';
  static const Duration splashDuration = Duration(seconds: 2);
}
