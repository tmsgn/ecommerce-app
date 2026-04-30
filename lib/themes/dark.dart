import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: Colors.white,
    onPrimary: Color(0xFF09090B),
    secondary: Color(0xFFA1A1AA), // Zinc Gray
    onSecondary: Color(0xFF09090B),
    surface: Color(0xFF09090B), // Deep Black background
    onSurface: Colors.white,
    error: Color(0xFFEF4444),
    tertiary: Color(0xFF27272A), // Dark zinc for borders/cards
    inversePrimary: Color(0xFFFAFAFA),
  ),
  scaffoldBackgroundColor: const Color(0xFF09090B),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: GoogleFonts.outfit(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
  ),
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
    displayLarge: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
    headlineMedium: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.inter(color: const Color(0xFFE4E4E7), fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.inter(color: const Color(0xFFA1A1AA)),
    bodyMedium: GoogleFonts.inter(color: const Color(0xFFA1A1AA)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF09090B),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF18181B), // Slightly lighter than bg
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white, width: 1.5),
    ),
    labelStyle: GoogleFonts.inter(color: const Color(0xFFA1A1AA)),
    hintStyle: GoogleFonts.inter(color: const Color(0xFF71717A)),
  ),
);
