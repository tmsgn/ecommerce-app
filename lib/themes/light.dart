import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF111827), // Deep Black
    onPrimary: Colors.white,
    secondary: Color(0xFF4B5563), // Slate Gray
    onSecondary: Colors.white,
    surface: Color(0xFFF9FAFB), // Very light gray background
    onSurface: Color(0xFF111827),
    error: Color(0xFFEF4444), // Red
    tertiary: Color(0xFFE5E7EB), // Light gray for borders/dividers
    inversePrimary: Color(0xFF1F2937),
  ),
  scaffoldBackgroundColor: const Color(0xFFF9FAFB),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    iconTheme: const IconThemeData(color: Color(0xFF111827)),
    titleTextStyle: GoogleFonts.outfit(
      color: const Color(0xFF111827),
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
  ),
  textTheme: GoogleFonts.interTextTheme().copyWith(
    displayLarge: GoogleFonts.outfit(color: const Color(0xFF111827), fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.outfit(color: const Color(0xFF111827), fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.outfit(color: const Color(0xFF111827), fontWeight: FontWeight.w600),
    headlineMedium: GoogleFonts.outfit(color: const Color(0xFF111827), fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.outfit(color: const Color(0xFF111827), fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.inter(color: const Color(0xFF374151), fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.inter(color: const Color(0xFF4B5563)),
    bodyMedium: GoogleFonts.inter(color: const Color(0xFF4B5563)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF111827),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF3F4F6),
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
      borderSide: const BorderSide(color: Color(0xFF111827), width: 1.5),
    ),
    labelStyle: GoogleFonts.inter(color: const Color(0xFF6B7280)),
    hintStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF)),
  ),
);
