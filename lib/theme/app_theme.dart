import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color darkThemePrimaryBase = Color(0xFF033955);
  static const Color darkThemeGradientAccent = Color(0xFF00BFEB);
  static const Color darkThemeSlidesBackground = Color(0xFF00BFEB);

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkThemePrimaryBase,
        brightness: Brightness.dark,
        primary: darkThemePrimaryBase,
        onPrimary: Colors.white,
        secondary: darkThemeGradientAccent,
        onSecondary: Colors.white,
        surface: darkThemePrimaryBase.withOpacity(0.9),
        onSurface: Colors.white.withOpacity(0.87),
        background: const Color(0xFF012338),
        onBackground: Colors.white.withOpacity(0.87),
        error: Colors.redAccent.shade200,
        onError: Colors.black,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme.apply(
            bodyColor: Colors.white.withOpacity(0.87),
            displayColor: Colors.white.withOpacity(0.87),
          )),
      appBarTheme: AppBarTheme(
        foregroundColor: Colors.white.withOpacity(0.95),
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.95),
          fontFamily: GoogleFonts.cairo().fontFamily,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkThemePrimaryBase,
        selectedItemColor: darkThemeGradientAccent,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(),
      ),
    );
  }
} 