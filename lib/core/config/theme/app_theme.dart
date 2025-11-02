import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Dark Mode Color Palette ---
  static const Color primaryBackground = Color(0xFF12172D);
  static const Color secondaryBackground = Color(0xFF1F295B);
  static const Color accentCyan = Color(0xFF00FFFF);
  static const Color accentMagenta = Color(0xFFF800FF);
  static const Color textPrimary = Color(0xE6FFFFFF); // 90% opacity
  static const Color textSecondary = Color(0xB3B0B8E7); // 70% opacity
  static const Color glassBackground = Color(0xA62E285D);
  static const Color glowColor = Color(0x2600FFFF);

  // --- Light Mode Color Palette ---
  static const Color primaryBackgroundLight = Color(0xFFF0F2FF);
  static const Color secondaryBackgroundLight = Color(0xFFFFFFFF);
  static const Color accentPurpleLight = Color(0xFF6A00F4);
  static const Color accentPinkLight = Color(0xFFE342FF);
  static const Color textPrimaryLight = Color(0xFF12172D);
  static const Color textSecondaryLight = Color(0xFF5C6898);
  static const Color glassBackgroundLight = Color(0xB3FFFFFF);
  static const Color glowColorLight = Color(0x1A6A00F4);

  // --- Dark Theme Definition ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: accentCyan,
    scaffoldBackgroundColor: Colors.transparent, // Background handled by a gradient container.
    colorScheme: const ColorScheme.dark(
      primary: accentCyan,
      secondary: accentMagenta,
      background: primaryBackground,
      surface: secondaryBackground,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onBackground: textPrimary,
      onSurface: textPrimary,
      surfaceVariant: secondaryBackground,
      onSurfaceVariant: textSecondary,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.bebasNeue(fontSize: 48, color: textPrimary),
      headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
      headlineMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.normal, color: textPrimary),
      bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal, color: textSecondary),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: accentCyan,
      unselectedItemColor: textSecondary,
      selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(),
    ),
  );

  // --- Light Theme Definition ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: accentPurpleLight,
    scaffoldBackgroundColor: primaryBackgroundLight,
    colorScheme: const ColorScheme.light(
      primary: accentPurpleLight,
      secondary: accentPinkLight,
      background: primaryBackgroundLight,
      surface: secondaryBackgroundLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textPrimaryLight,
      onSurface: textPrimaryLight,
      surfaceVariant: Color(0xFFE8EAF6),
      onSurfaceVariant: textSecondaryLight,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.bebasNeue(fontSize: 48, color: textPrimaryLight),
      headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryLight),
      headlineMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimaryLight),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimaryLight),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.normal, color: textPrimaryLight),
      bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal, color: textSecondaryLight),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimaryLight),
      titleTextStyle: TextStyle(color: textPrimaryLight),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: accentPurpleLight,
      unselectedItemColor: textSecondaryLight,
      selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(),
    ),
  );
}
