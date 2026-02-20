import 'package:flutter/material.dart';

class NeonTheme {
  static const Color amoledBlack = Color(0xFF000000);
  static const Color neonBlue = Color(0xFF00BFFF);
  static const Color neonViolet = Color(0xFF8A2BE2);
  static const Color accentGreen = Color(0xFF39FF14);
  static const Color accentRed = Color(0xFFFF3131);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: amoledBlack,
      colorScheme: const ColorScheme.dark(
        primary: neonBlue,
        secondary: neonViolet,
        surface: Color(0xFF121212),
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: amoledBlack,
        foregroundColor: neonBlue,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: neonBlue, width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: neonBlue, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.white70),
      ),
    );
  }
}
