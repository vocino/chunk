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

  // Responsive scaling
  static double scaleFactor(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return (shortestSide / 390).clamp(0.85, 1.6);
  }

  // Base text styles (unscaled, for ThemeData)
  static const TextStyle _headingLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w300,
    color: foreground,
    height: 1.2,
  );

  static const TextStyle _headingMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: foreground,
    height: 1.3,
  );

  static const TextStyle _bodyLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w300,
    color: foreground,
    height: 1.4,
  );

  // Responsive text styles
  static TextStyle headingLarge(BuildContext context) =>
      _headingLarge.copyWith(fontSize: 48 * scaleFactor(context));

  static TextStyle headingMedium(BuildContext context) =>
      _headingMedium.copyWith(fontSize: 32 * scaleFactor(context));

  static TextStyle bodyLarge(BuildContext context) =>
      _bodyLarge.copyWith(fontSize: 24 * scaleFactor(context));

  // Button Style
  static final ButtonStyle primaryButtonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return purple.withValues(alpha: 0.40);
      }
      return purple.withValues(alpha: 0.20);
    }),
    foregroundColor: WidgetStateProperty.all(foreground),
    minimumSize: WidgetStateProperty.all(const Size(double.infinity, 72)),
    shape: WidgetStateProperty.resolveWith((states) {
      final borderOpacity =
          states.contains(WidgetState.pressed) ? 0.6 : 0.35;
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: purple.withValues(alpha: borderOpacity),
          width: 1.0,
        ),
      );
    }),
    elevation: WidgetStateProperty.all(0),
    overlayColor: WidgetStateProperty.all(Colors.transparent),
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
        displayLarge: _headingLarge,
        displayMedium: _headingMedium,
        bodyLarge: _bodyLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle,
      ),
    );
  }
}
