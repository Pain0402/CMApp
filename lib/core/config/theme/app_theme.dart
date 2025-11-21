import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  // --- Dark Mode Color Palette ---
  static const Color primaryBackground = Color(0xFF12172D);
  static const Color secondaryBackground = Color(0xFF1F295B);
  static const Color accentCyan = Color.fromARGB(255, 0, 191, 255);
  static const Color accentMagenta = Color.fromARGB(255, 133, 25, 248);
  static const Color textPrimary = Color(0xE6FFFFFF); // 90% opacity
  static const Color textSecondary = Color(0xB3B0B8E7); // 70% opacity
  static const Color glassBackground = Color(0xA62E285D);
  static const Color glowColor = Color(0x2600FFFF);

  // --- Light Mode Color Palette ---
  static const Color primaryBackgroundLight = Color(0xFFF0F2FF);
  static const Color secondaryBackgroundLight = Color(0xFFFFFFFF);
  static const Color accentPurpleLight = Color(0xFF6A00F4);
  static const Color accentPinkLight = Color.fromARGB(255, 133, 25, 248);
  static const Color textPrimaryLight = Color(0xFF12172D);
  static const Color textSecondaryLight = Color(0xFF5C6898);
  static const Color glassBackgroundLight = Color(0xB3FFFFFF);
  static const Color glowColorLight = Color(0x1A6A00F4);

  static const LinearGradient darkLinearGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF12172D), 
      Color.fromARGB(255, 22, 128, 220), 
      Color(0xFF251C3B), 
    ],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient lightLinearGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromARGB(255, 184, 190, 255),
      Color.fromARGB(255, 255, 212, 255),
    ],
    stops: [0.2, 1.0],
  );

  // --- Dark Theme Definition ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: accentCyan,
    scaffoldBackgroundColor: Colors.transparent, 
    colorScheme: const ColorScheme.dark(
      primary: accentCyan,
      secondary: accentMagenta,
      surface: secondaryBackground,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: textPrimary,
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
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold)
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: secondaryBackground,
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
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.light(
      primary: accentPurpleLight,
      secondary: accentPinkLight,
      surface: secondaryBackgroundLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryLight,
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

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const _themeKey = 'theme_mode_v1';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      
      if (savedTheme == 'dark') {
        state = ThemeMode.dark;
      } else if (savedTheme == 'light') {
        state = ThemeMode.light;
      } else {
        state = ThemeMode.system;
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, isDark ? 'dark' : 'light');
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
  
  Future<void> setSystemTheme() async {
    state = ThemeMode.system;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeKey);
    } catch (e) {
      debugPrint('Error resetting theme: $e');
    }
  }
}