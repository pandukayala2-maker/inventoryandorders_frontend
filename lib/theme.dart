// lib/theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF0A84FF);
  static const Color lightBlue = Color(0xFFE3F1FF);
  static const Color darkText = Color(0xFF1E1E1E);
  static const Color lightText = Color.fromARGB(255, 167, 14, 181);

  static ThemeData themeData = ThemeData(
    useMaterial3: true,
    fontFamily: "Roboto",

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
    ),

    scaffoldBackgroundColor: const Color(0xFFF5F7FA),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: lightText),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
  );
}
