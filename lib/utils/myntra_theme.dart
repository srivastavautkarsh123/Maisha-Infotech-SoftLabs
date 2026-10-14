import 'package:flutter/material.dart';

class MyntraColors {
  static const Color primary = Color(0xFFFF3F6C); // Iconic Myntra Pink
  static const Color primaryGradientStart = Color(0xFFFF3F6C);
  static const Color primaryGradientEnd = Color(0xFFFF527B);
  
  static const Color textPrimary = Color(0xFF282C3F);
  static const Color textSecondary = Color(0xFF535766);
  static const Color textMuted = Color(0xFF94969F);
  
  static const Color background = Color(0xFFF5F5F6);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFEAEAEC);
  
  static const Color greenBadge = Color(0xFF03A685);
  static const Color orangeOffer = Color(0xFFFF905A);
  static const Color accentOrange = Color(0xFFFF905A);
  static const Color starAmber = Color(0xFFFFB800);
}

class MyntraTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: MyntraColors.surface,
      primaryColor: MyntraColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MyntraColors.primary,
        primary: MyntraColors.primary,
        surface: MyntraColors.surface,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: MyntraColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: MyntraColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: MyntraColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyntraColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: MyntraColors.textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: MyntraColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: MyntraColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: MyntraColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
