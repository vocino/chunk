import 'package:flutter/material.dart';

class AppTheme {
  // Dracula Theme Colors
  static const Color background = Color(0xFF282A36);
  static const Color currentLine = Color(0xFF6272A4);
  static const Color selection = Color(0xFF44475A);
  static const Color foreground = Color(0xFFF8F8F2);
  static const Color comment = Color(0xFF6272A4);
  static const Color red = Color(0xFFFF5555);
  static const Color orange = Color(0xFFFFB86C);
  static const Color yellow = Color(0xFFF1FA8C);
  static const Color green = Color(0xFF50FA7B);
  static const Color cyan = Color(0xFF8BE9FD);
  static const Color purple = Color(0xFFBD93F9);
  static const Color pink = Color(0xFFFF79C6);

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w300,
    color: foreground,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: foreground,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w300,
    color: foreground,
    height: 1.4,
  );

  // Button Style
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: purple,
    foregroundColor: background,
    minimumSize: const Size(double.infinity, 72),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 0,
  );

  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: purple,
        brightness: Brightness.dark,
      ).copyWith(
        surface: background,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      iconTheme: const IconThemeData(color: comment),
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
