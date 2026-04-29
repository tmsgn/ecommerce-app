import 'package:flutter/material.dart';

const Color kDarkBg = Color(0xFF0F0E1A);
const Color kDarkSurface = Color(0xFF1A1A2E);
const Color kDarkCard = Color(0xFF252540);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Roboto',
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF8A7EF8),
    secondary: const Color(0xFFFF8E8E),
    surface: kDarkBg,
    tertiary: kDarkCard,
    inversePrimary: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  ),
  scaffoldBackgroundColor: kDarkBg,
  appBarTheme: const AppBarTheme(
    backgroundColor: kDarkSurface,
    foregroundColor: Colors.white,
    elevation: 0,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF8A7EF8),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kDarkCard,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF3A3A5C)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF3A3A5C)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF8A7EF8), width: 1.5),
    ),
    labelStyle: const TextStyle(color: Color(0xFFAAAAAA)),
  ),
  cardTheme: CardTheme(
    color: kDarkCard,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
);
