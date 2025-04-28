// Fichier utils/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales
  static const primaryColor = Color(0xFF3F51B5);
  static const secondaryColor = Color(0xFFFF4081);
  static const tertiaryColor = Color(0xFF4CAF50);
  
  // Couleurs des commerces
  static const fixedBusinessColor = Color(0xFF2196F3);
  static const mobileBusinessColor = Color(0xFF4CAF50);
  
  // Couleurs de statut
  static const openColor = Color(0xFF4CAF50);
  static const closedColor = Color(0xFFE53935);
  static const pendingColor = Color(0xFFFF9800);
  static const processingColor = Color(0xFF2196F3);
  static const completedColor = Color(0xFF4CAF50);
  static const cancelledColor = Color(0xFFE53935);
  
  // Rayons de bordure
  static const smallRadius = 8.0;
  static const mediumRadius = 12.0;
  static const largeRadius = 16.0;
  
  // Thème complet
  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(smallRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(smallRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallRadius),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mediumRadius),
        ),
      ),
      dividerTheme: const DividerThemeData(
        thickness: 1.0,
        space: 24.0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(smallRadius),
        ),
      ),
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
  
  // Ombres
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 2),
      blurRadius: 8,
    ),
  ];
  
  static List<BoxShadow> bottomShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, -4),
      blurRadius: 8,
    ),
  ];
}