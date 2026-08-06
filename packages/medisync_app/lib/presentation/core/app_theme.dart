import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores del manual de marca MediSync
  static const Color azulProfundo = Color(0xFF0D1B2A);
  static const Color azulPrimario = Color(0xFF1E3A8A);
  static const Color azulElectrico = Color(0xFF0EA5E9);
  static const Color cian = Color(0xFF22D3EE);
  static const Color verdeExito = Color(0xFF22C55E);
  static const Color grisClaro = Color(0xFFF2F4F8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: grisClaro,
      primaryColor: azulPrimario,
      colorScheme: const ColorScheme.light(
        primary: azulPrimario,
        secondary: azulElectrico,
        tertiary: cian,
        surface: grisClaro,
        error: Colors.redAccent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: azulPrimario,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
