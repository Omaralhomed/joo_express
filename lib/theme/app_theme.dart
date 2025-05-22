import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeumorphicConstants {
  // Base colors for Neumorphic design
  static const Color primaryBlue = Color(0xFF4C9AFF);
  static const Color secondaryBlue = Color(0xFF2B7FFF);
  static const Color primaryGreen = Color(0xFF3AD079);
  static const Color tealGreen = Color(0xFF2CC995);
  static const Color baseColor = Color(0xFFF0F0F3);
  static const Color cardColor = Colors.white;
  static const Color lightColor = Color(0xFFFAFAFA);
  
  // Gradient colors
  static const Color gradientStart = Color(0xFF4C9AFF); // Light blue
  static const Color gradientMiddle1 = Color(0xFF2B7FFF); // Medium blue
  static const Color gradientMiddle2 = Color(0xFF2CC995); // Teal
  static const Color gradientEnd = Color(0xFF3AD079); // Green
  
  // Shadow colors
  static const Color shadowDark = Color(0xFFD1D9E6);
  static const Color shadowLight = Colors.white;
  
  // Border radius
  static const double borderRadius = 25.0;
  static const double buttonRadius = 20.0;
  
  // Glassmorphic effect
  static List<BoxShadow> getGlassShadow() {
    return [
      BoxShadow(
        color: shadowDark.withOpacity(0.1),
        offset: const Offset(5, 5),
        blurRadius: 15,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: shadowLight.withOpacity(0.9),
        offset: const Offset(-5, -5),
        blurRadius: 15,
        spreadRadius: 1,
      ),
    ];
  }

  // Neumorphic shadow
  static List<BoxShadow> getNeumorphicShadow({bool isPressed = false}) {
    if (isPressed) {
      return [
        BoxShadow(
          color: shadowDark.withOpacity(0.2),
          offset: const Offset(2, 2),
          blurRadius: 5,
        ),
        BoxShadow(
          color: shadowLight.withOpacity(0.9),
          offset: const Offset(-2, -2),
          blurRadius: 5,
        ),
      ];
    }
    return [
      BoxShadow(
        color: shadowDark.withOpacity(0.2),
        offset: const Offset(6, 6),
        blurRadius: 15,
      ),
      BoxShadow(
        color: shadowLight.withOpacity(0.9),
        offset: const Offset(-6, -6),
        blurRadius: 15,
      ),
    ];
  }

  static BoxDecoration getGlassmorphicDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(0.3),
        width: 1.5,
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.6),
          Colors.white.withOpacity(0.2),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 15,
          spreadRadius: -5,
        ),
      ],
    );
  }

  static BoxDecoration getMainGradientDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          gradientStart.withOpacity(0.9),
          gradientEnd.withOpacity(0.9),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 15,
          spreadRadius: -5,
        ),
      ],
    );
  }

  // Get app background gradient
  static BoxDecoration getAppBackgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.3, 0.6, 1.0],
        colors: [
          gradientStart.withOpacity(0.9),
          gradientMiddle1.withOpacity(0.8),
          gradientMiddle2.withOpacity(0.7),
          gradientEnd.withOpacity(0.9),
        ],
      ),
    );
  }

  // Get content overlay gradient
  static BoxDecoration getContentOverlayDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.9),
          Colors.white.withOpacity(0.8),
          Colors.white.withOpacity(0.6),
        ],
      ),
    );
  }
}

class AppTheme {
  static ThemeData neumorphicTheme() {
    return ThemeData(
      primaryColor: NeumorphicConstants.primaryBlue,
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.cairoTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeumorphicConstants.gradientStart,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NeumorphicConstants.buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeumorphicConstants.buttonRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeumorphicConstants.buttonRadius),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeumorphicConstants.buttonRadius),
          borderSide: BorderSide(
            color: NeumorphicConstants.gradientStart,
            width: 1.5,
          ),
        ),
      ),
    );
  }
} 