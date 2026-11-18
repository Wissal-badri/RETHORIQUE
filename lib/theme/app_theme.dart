import 'package:flutter/material.dart';

class AppColors {
  // Palette classique et noble
  static const Color background = Color(0xFFFAF7F0); // Blanc cassé
  static const Color card = Color(0xFFF1E9DA); // Beige clair parchemin
  static const Color border = Color(0xFFD9CBB0); // Sable / bordure fine
  static const Color navy = Color(0xFF14284B); // Bleu marine noble
  static const Color ink = Color(0xFF1B2437); // Marine très foncé (texte)
  static const Color gold = Color(0xFFA8873A); // Doré discret
  static const Color goldLight = Color(0xFFD4AF37); // Doré lumineux
  
  // Correction
  static const Color success = Color(0xFF5E7F5B); // Vert sauge
  static const Color error = Color(0xFF8E3B3B); // Bordeaux
  static const Color warning = Color(0xFFC88232); // Ambre / orange
  
  static const Color surfaceElevated = Color(0xFFFDFBF7);
}

class AppTheme {
  static const String fontTinos = 'Tinos';
  static const String fontPinyon = 'PinyonScript';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navy,
        onPrimary: Colors.white,
        secondary: AppColors.gold,
        onSecondary: Colors.white,
        surface: AppColors.card,
        onSurface: AppColors.ink,
        error: AppColors.error,
        onError: Colors.white,
      ),
      fontFamily: fontTinos,
      fontFamilyFallback: const ['Times New Roman', 'serif'],
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontPinyon,
          fontSize: 28,
          color: Colors.white,
          letterSpacing: 1.0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.card,
        selectedColor: AppColors.navy,
        secondarySelectedColor: AppColors.navy,
        labelStyle: const TextStyle(
          fontFamily: fontTinos,
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: fontTinos,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: fontTinos,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.gold, width: 1),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.navy, width: 1.2),
          textStyle: const TextStyle(
            fontFamily: fontTinos,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontPinyon,
          fontSize: 42,
          fontWeight: FontWeight.bold,
          color: AppColors.navy,
        ),
        displayMedium: TextStyle(
          fontFamily: fontPinyon,
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: AppColors.navy,
        ),
        titleLarge: TextStyle(
          fontFamily: fontTinos,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.navy,
          letterSpacing: 0.5,
        ),
        titleMedium: TextStyle(
          fontFamily: fontTinos,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.ink,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontTinos,
          fontSize: 17,
          color: AppColors.ink,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontTinos,
          fontSize: 15,
          color: AppColors.ink,
          height: 1.5,
        ),
      ),
    );
  }
}
