import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryBlue = Color(0xFF6B9BD1);
  static const Color primaryPurple = Color(0xFF9B8FD1);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF2C2C2C);
  static const Color buttonBlue = Color(0xFF5A8AC4);

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w600,
    color: textDark,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: textDark,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: textDark,
    height: 1.4,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Button Style
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: buttonBlue,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 72),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 2,
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: headingLarge,
        displayMedium: headingMedium,
        bodyLarge: bodyLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle,
      ),
    );
  }
}
