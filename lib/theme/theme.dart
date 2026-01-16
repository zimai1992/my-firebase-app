import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 🏥 1. Medical Palette (Defined locally for safety)
const primaryTeal = Color(0xFF009688); // Deep Medical Teal
const deepTeal = Color(0xFF00695C);    // Darker accent
const softTeal = Color(0xFFE0F2F1);    // Light background accent
const errorRed = Color(0xFFE57373);    // Soft warning red
const surfaceWhite = Color(0xFFF5F7FA); // Soft paper-white (Easy on eyes)

// 🏥 2. Light Theme (The Default)
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: primaryTeal,
  scaffoldBackgroundColor: surfaceWhite, // Replaces harsh white background
  
  // Color Scheme
  colorScheme: const ColorScheme.light(
    primary: primaryTeal,
    secondary: deepTeal,
    surface: Colors.white,
    error: errorRed,
    onPrimary: Colors.white,
    onSurface: Colors.black87,
  ),

  // Typography (Poppins - Modern & Clean)
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: Colors.grey[800],
    displayColor: deepTeal,
  ),

  // App Bar (Clean & Professional)
  appBarTheme: AppBarTheme(
    backgroundColor: primaryTeal,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 20, 
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  ),

  // Card Theme (The "Floating Island" look)
  cardTheme: CardThemeData( 
    elevation: 2,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),

  // Input Fields (Rounded & Friendly)
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

  // Buttons (Rounded Pills)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryTeal,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 2,
      textStyle: GoogleFonts.poppins(
        fontSize: 16, 
        fontWeight: FontWeight.w600
      ),
    ),
  ),
  
  // Floating Action Button (The "Scan" Button)
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: deepTeal,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
  ),
);

// 🏥 3. Dark Theme (High Contrast for Elderly)
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: primaryTeal,
  scaffoldBackgroundColor: const Color(0xFF121212), // True Black
  
  colorScheme: const ColorScheme.dark(
    primary: primaryTeal,
    secondary: softTeal,
    surface: Color(0xFF1E1E1E), // Dark Grey Surface
    onPrimary: Colors.white,
  ),

  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),

  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
  ),

  cardTheme: CardThemeData( 
    elevation: 2,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
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