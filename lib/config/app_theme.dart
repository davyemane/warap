import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs primaires
  static const Color primaryColor = Colors.blue;
  static const Color accentColor = Colors.blueAccent;
  
  // Thème clair
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      scaffoldBackgroundColor: Colors.white,
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
  
  // Thème sombre
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: const Color(0xFF202020),
        background: const Color(0xFF121212),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF202020),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: CardTheme(
        color: const Color(0xFF202020),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue[200],
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue[200],
          side: BorderSide(color: Colors.blue[200]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[200]!, width: 2),
        ),
        fillColor: const Color(0xFF303030),
        filled: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF202020),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF202020),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}