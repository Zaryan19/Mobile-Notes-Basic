import 'package:flutter/material.dart';

/// De Stijl Design System Tokens & Theme Configuration
/// Strictly adheres to Theo van Doesburg and Piet Mondrian's 1917 neoplasticism:
/// - 0px border radius everywhere (STRICTLY NO rounded corners)
/// - Thick solid black lines (2dp - 4dp)
/// - Pure primary colors: Red (#FF0000), Blue (#0000FF), Yellow (#FFFF00)
/// - Solid white surfaces (#FFFFFF) and pure black (#000000)
/// - Hard solid offset shadows (0 blur)
class DeStijlTheme {
  // --- De Stijl Color Palette ---
  static const Color primaryRed = Color(0xFFFF0000);
  static const Color primaryBlue = Color(0xFF0000FF);
  static const Color primaryYellow = Color(0xFFFFFF00);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF808080);
  static const Color lightGrey = Color(0xFFF4F4F4);

  // --- Borders ---
  static const double borderWidth = 2.0;
  static const double thickBorderWidth = 4.0;

  static const Border borderAll = Border.fromBorderSide(
    BorderSide(color: black, width: borderWidth),
  );

  static const Border borderBottomOnly = Border(
    bottom: BorderSide(color: black, width: borderWidth),
  );

  static const Border borderTopOnly = Border(
    top: BorderSide(color: black, width: borderWidth),
  );

  // --- Hard Solid Shadows (0 Blur) ---
  static const List<BoxShadow> hardShadow = [
    BoxShadow(
      color: black,
      offset: Offset(4.0, 4.0),
      blurRadius: 0.0,
      spreadRadius: 0.0,
    ),
  ];

  static const List<BoxShadow> hardShadowSmall = [
    BoxShadow(
      color: black,
      offset: Offset(2.0, 2.0),
      blurRadius: 0.0,
      spreadRadius: 0.0,
    ),
  ];

  // --- Typography ---
  static const List<String> fontHelvetica = [
    'Helvetica',
    'Arial',
    'sans-serif',
  ];

  static const List<String> fontMono = [
    'JetBrains Mono',
    'Courier New',
    'Courier',
    'monospace',
  ];

  static TextStyle displayH1({Color color = black}) => TextStyle(
        fontFamily: fontHelvetica.first,
        fontFamilyFallback: fontHelvetica,
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: color,
      );

  static TextStyle h2({Color color = black}) => TextStyle(
        fontFamily: fontHelvetica.first,
        fontFamilyFallback: fontHelvetica,
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle body({Color color = black, double height = 1.5}) =>
      TextStyle(
        fontFamily: fontHelvetica.first,
        fontFamilyFallback: fontHelvetica,
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: height,
        color: color,
      );

  static TextStyle snippet({Color color = grey}) => TextStyle(
        fontFamily: fontHelvetica.first,
        fontFamilyFallback: fontHelvetica,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  static TextStyle metadata({Color color = grey}) => TextStyle(
        fontFamily: fontMono.first,
        fontFamilyFallback: fontMono,
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.2,
      );

  static TextStyle monoBold({Color color = black, double size = 12.0}) =>
      TextStyle(
        fontFamily: fontMono.first,
        fontFamilyFallback: fontMono,
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
      );

  // --- Global ThemeData ---
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: white,
      primaryColor: primaryBlue,
      canvasColor: white,
      splashFactory: NoSplash.splashFactory, // Mechanical tactile feel, no soft ripple
      highlightColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Helvetica',
          fontFamilyFallback: ['Arial', 'sans-serif'],
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          color: black,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: black,
        selectionColor: Color(0x66FFFF00), // Transparent yellow selection
        selectionHandleColor: black,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: white,
        elevation: 0.0,
        shape: BeveledRectangleBorder(
          side: BorderSide(color: black, width: borderWidth),
        ),
      ),
    );
  }
}

