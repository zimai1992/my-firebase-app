import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 🏥 1. Medical Palette
const primaryTeal = Color(0xFF009688); // Deep Medical Teal
const deepTeal = Color(0xFF00695C);    // Darker accent
const softTeal = Color(0xFFE0F2F1);    // Light background accent
const errorRed = Color(0xFFE57373);    // Soft warning red
const surfaceWhite = Color(0xFFF5F7FA); // Soft paper-white

// 🏥 Helper for resilient fonts
TextTheme _buildResilientTextTheme(TextTheme base, Color? bodyColor, Color? displayColor) {
  try {
    return GoogleFonts.poppinsTextTheme(base).apply(
      bodyColor: bodyColor,
      displayColor: displayColor,
    );
  } catch (e) {
    // Fallback to system fonts if Google Fonts fail
    return base.apply(
      bodyColor: bodyColor,
      displayColor: displayColor,
      fontFamily: 'sans-serif',
    );
  }
}

TextStyle _buildResilientTextStyle(TextStyle base, {FontWeight? fontWeight, double? fontSize, double? letterSpacing}) {
  try {
    return GoogleFonts.poppins(
      textStyle: base,
      fontWeight: fontWeight,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
    );
  } catch (e) {
    return base.copyWith(
      fontWeight: fontWeight,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      fontFamily: 'sans-serif',
    );
  }
}

// 🏥 2. Light Theme
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: primaryTeal,
  scaffoldBackgroundColor: surfaceWhite,
  
  colorScheme: const ColorScheme.light(
    primary: primaryTeal,
    secondary: deepTeal,
    surface: Colors.white,
    error: errorRed,
    onPrimary: Colors.white,
    onSurface: Colors.black87,
  ),

  textTheme: _buildResilientTextTheme(ThemeData.light().textTheme, Colors.grey[800], deepTeal),

  appBarTheme: AppBarTheme(
    backgroundColor: primaryTeal,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: _buildResilientTextStyle(
      const TextStyle(fontSize: 20, color: Colors.white),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  ),

  cardTheme: CardThemeData( 
    elevation: 2,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[200]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryTeal, width: 2),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryTeal,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 2,
      textStyle: _buildResilientTextStyle(
        const TextStyle(fontSize: 16),
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: deepTeal,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
  ),
);

// 🏥 3. Dark Theme
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: primaryTeal,
  scaffoldBackgroundColor: const Color(0xFF121212),
  
  colorScheme: const ColorScheme.dark(
    primary: primaryTeal,
    secondary: softTeal,
    surface: Color(0xFF1E1E1E),
    onPrimary: Colors.white,
  ),

  textTheme: _buildResilientTextTheme(ThemeData.dark().textTheme, Colors.white70, primaryTeal),

  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    titleTextStyle: _buildResilientTextStyle(
      const TextStyle(fontSize: 20, color: Colors.white),
      fontWeight: FontWeight.w600,
    ),
  ),

  cardTheme: CardThemeData( 
    elevation: 2,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: const Color(0xFF1E1E1E),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryTeal,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
  ),
);
