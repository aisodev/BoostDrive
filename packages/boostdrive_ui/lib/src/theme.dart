import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BoostDriveTheme {
  // Brand Colors - New High-end palette
  static const Color primaryBlue = Color(0xFF0D93F2); 
  static const Color backgroundDark = Color(0xFF101B22);
  static const Color surfaceDark = Color(0xFF1A262E); 
  static const Color accentBlue = Color(0xFF007AFF);
  static const Color backgroundLight = Color(0xFFF5F7F8);
  
  static const String globalBackgroundImage = 'assets/images/range_rover_hero.png';
  
  static const Color textBody = Color(0xFFEBEBF5);
  static const Color textDim = Color(0xFF90B2CB); // Based on HTML slate-500/slate-400

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSurface: textBody,
        background: backgroundDark,
      ),
      textTheme: GoogleFonts.manropeTextTheme(
        Theme.of(context).textTheme,
      ).apply(
        bodyColor: textBody,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true, // Match HTML "Create Account" center title
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white10, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: textDim, fontSize: 13, fontWeight: FontWeight.bold),
        hintStyle: const TextStyle(color: Colors.white24),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

}
