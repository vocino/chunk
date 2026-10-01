import 'package:flutter/material.dart';

class AppTheme {
  // Catppuccin Mocha - Base
  static const Color base = Color(0xFF1E1E2E);
  static const Color mantle = Color(0xFF181825);
  static const Color crust = Color(0xFF11111B);
  static const Color surface0 = Color(0xFF313244);
  static const Color surface1 = Color(0xFF45475A);
  static const Color surface2 = Color(0xFF585B70);
  static const Color overlay0 = Color(0xFF6C7086);
  static const Color overlay1 = Color(0xFF7F849C);
  static const Color overlay2 = Color(0xFF9399B2);
  static const Color subtext0 = Color(0xFFA6ADC8);
  static const Color subtext1 = Color(0xFFBAC2DE);
  static const Color text = Color(0xFFCDD6F4);

  // Catppuccin Mocha - Accents
  static const Color rosewater = Color(0xFFF5E0DC);
  static const Color flamingo = Color(0xFFF2CDCD);
  static const Color pink = Color(0xFFF5C2E7);
  static const Color mauve = Color(0xFFCBA6F7);
  static const Color red = Color(0xFFF38BA8);
  static const Color maroon = Color(0xFFEBA0AC);
  static const Color peach = Color(0xFFFAB387);
  static const Color yellow = Color(0xFFF9E2AF);
  static const Color green = Color(0xFFA6E3A1);
  static const Color teal = Color(0xFF94E2D5);
  static const Color sky = Color(0xFF89DCEB);
  static const Color sapphire = Color(0xFF74C7EC);
  static const Color blue = Color(0xFF89B4FA);
  static const Color lavender = Color(0xFFB4BEFE);

  // Backward-compatible aliases
  static const Color background = base;
  static const Color currentLine = overlay0;
  static const Color selection = surface0;
  static const Color foreground = text;
  static const Color comment = overlay1;
  static const Color purple = mauve;
  static const Color cyan = sky;
  static const Color orange = peach;

  // Gradient Utilities
  static const LinearGradient accentGradient = LinearGradient(
    colors: [teal, mauve],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [base, mantle],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient glowGradient(Color color) => LinearGradient(
    colors: [
      color.withValues(alpha: 0.3),
      color.withValues(alpha: 0.0),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient borderGradient({
    Color from = teal,
    Color to = mauve,
  }) => LinearGradient(
    colors: [from, to],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Responsive scaling
  static double scaleFactor(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return (shortestSide / 390).clamp(0.85, 1.6);
  }

  // Spacing scale (logical px, pre-scale). Prefer these over ad-hoc values.
  static const double spaceXS = 8;
  static const double spaceSM = 12;
  static const double spaceMD = 16;
  static const double spaceLG = 24;
  static const double spaceXL = 32;
  static const double spaceXXL = 48;

  // Typeface. Bundled (see pubspec + assets/fonts/OFL.txt) so the app renders
  // identically offline. Only 400/600/700/800 ship — keep every TextStyle on
  // those weights.
  static const String fontFamily = 'Nunito';

  // Base text styles (unscaled, for ThemeData). Hierarchy, top to bottom:
  // display (hero) > numerals (hero times) > title (card titles) >
  // activity (break suggestion) > body (info) > label (actions) >
  // caption (micro-labels). Small text stays on subtext0 or brighter so it
  // never drops below ~4.5:1 on the base background.
  static const TextStyle _display = TextStyle(
    fontSize: 52,
    fontWeight: FontWeight.w800,
    color: text,
    height: 1.05,
    letterSpacing: -0.5,
  );

  static const TextStyle _numerals = TextStyle(
    fontSize: 76,
    fontWeight: FontWeight.w700,
    color: text,
    height: 1.0,
    letterSpacing: -0.8,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle _title = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: text,
    height: 1.1,
    letterSpacing: -0.25,
  );

  static const TextStyle _activity = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: text,
    height: 1.3,
  );

  static const TextStyle _body = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: text,
    height: 1.4,
  );

  static const TextStyle _label = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: subtext0,
    height: 1.3,
    letterSpacing: 0.5,
  );

  static const TextStyle _caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: overlay2,
    height: 1.3,
    letterSpacing: 0.8,
  );

  // Responsive text styles. Sizes scale with the viewport; tracking stays
  // fixed so it never loosens into letterspacing soup on tablets.
  static TextStyle display(BuildContext context) =>
      _display.copyWith(fontSize: 52 * scaleFactor(context));

  static TextStyle numerals(BuildContext context) =>
      _numerals.copyWith(fontSize: 76 * scaleFactor(context));

  static TextStyle title(BuildContext context) =>
      _title.copyWith(fontSize: 34 * scaleFactor(context));

  static TextStyle activity(BuildContext context) =>
      _activity.copyWith(fontSize: 26 * scaleFactor(context));

  static TextStyle body(BuildContext context) =>
      _body.copyWith(fontSize: 20 * scaleFactor(context));

  static TextStyle label(BuildContext context, [double size = 15]) =>
      _label.copyWith(fontSize: size * scaleFactor(context));

  static TextStyle caption(BuildContext context) =>
      _caption.copyWith(fontSize: 13 * scaleFactor(context));

  // Button Style
  static final ButtonStyle primaryButtonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return mauve.withValues(alpha: 0.40);
      }
      return mauve.withValues(alpha: 0.20);
    }),
    foregroundColor: WidgetStateProperty.all(text),
    minimumSize: WidgetStateProperty.all(const Size(double.infinity, 72)),
    shape: WidgetStateProperty.resolveWith((states) {
      final borderOpacity =
          states.contains(WidgetState.pressed) ? 0.6 : 0.35;
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: mauve.withValues(alpha: borderOpacity),
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
        seedColor: mauve,
        brightness: Brightness.dark,
      ).copyWith(
        surface: base,
      ),
      scaffoldBackgroundColor: base,
      fontFamily: fontFamily,
      iconTheme: const IconThemeData(color: overlay1),
      textTheme: const TextTheme(
        displayLarge: _display,
        displayMedium: _numerals,
        headlineMedium: _title,
        titleLarge: _activity,
        bodyLarge: _body,
        labelLarge: _label,
        labelMedium: _caption,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle,
      ),
    );
  }
}
