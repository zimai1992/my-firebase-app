import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 🧞 Rx Genie Palette
const rxBlue = Color(0xFF0077C2); // Vibrant Blue (Primary)
const rxGreen = Color(0xFF00C853); // Genie Green (Secondary)
const rxGold = Color(0xFFFFD700); // Magic Gold (Accent)

// Dark Theme Colors
const rxDarkBackground = Color(0xFF0F172A); // Deep Slate
const rxDarkSurface = Color(0xFF1E293B); // Lighter Slate

// Light Theme Colors
const rxLightBackground = Color(0xFFF8FAFC); // Slate 50
const rxLightSurface = Colors.white;
const rxText = Color(0xFF0F172A); // Slate 900

// 🌟 Immortal Palette (Gold) - Kept for legacy/premium
const immortalGold = Color(0xFFFFD700);
const immortalDarkSurface = Color(0xFF1C1917);

// 🖋️ Typography Helper
TextTheme _buildGodTierTypography(TextTheme base, Color textColor) {
  return GoogleFonts.outfitTextTheme(base).copyWith(
    displayLarge: GoogleFonts.outfit(
      fontSize: 57,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.25,
      color: textColor,
    ),
    displayMedium: GoogleFonts.outfit(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    displaySmall: GoogleFonts.outfit(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: textColor,
    ),
    headlineLarge: GoogleFonts.outfit(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    headlineMedium: GoogleFonts.outfit(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    headlineSmall: GoogleFonts.outfit(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    titleLarge: GoogleFonts.outfit(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    titleMedium: GoogleFonts.outfit(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: textColor,
    ),
    titleSmall: GoogleFonts.outfit(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: textColor,
    ),
    bodyLarge: GoogleFonts.outfit(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: textColor,
    ),
    bodyMedium: GoogleFonts.outfit(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: textColor,
    ),
    labelLarge: GoogleFonts.outfit(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.25, // All caps buttons
      color: textColor,
    ),
  );
}

// ☁️ Light Theme
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: rxBlue,
  scaffoldBackgroundColor: rxLightBackground,
  colorScheme: ColorScheme.fromSeed(
    seedColor: rxBlue,
    brightness: Brightness.light,
    primary: rxBlue,
    secondary: rxGreen,
    surface: rxLightSurface,
    onSurface: rxText,
    error: const Color(0xFFEF4444),
  ),
  textTheme: _buildGodTierTypography(ThemeData.light().textTheme, rxText),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: rxText,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: rxText,
      letterSpacing: 0.5,
    ),
    iconTheme: IconThemeData(color: rxText.withOpacity(0.8)),
  ),
  cardTheme: CardThemeData(
    color: rxLightSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: rxBlue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      elevation: 4,
      shadowColor: rxBlue.withOpacity(0.4),
    ),
  ),
  iconTheme: IconThemeData(color: rxText.withOpacity(0.7)),
  dividerTheme: DividerThemeData(color: rxText.withOpacity(0.1)),
);

// 🌌 Dark Theme
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: rxBlue,
  scaffoldBackgroundColor: rxDarkBackground,
  colorScheme: ColorScheme.fromSeed(
    seedColor: rxBlue,
    brightness: Brightness.dark,
    primary: rxBlue,
    secondary: rxGreen,
    surface: rxDarkSurface,
    onSurface: Colors.white,
    error: const Color(0xFFF87171),
  ),
  textTheme: _buildGodTierTypography(
      ThemeData.dark().textTheme, const Color(0xFFF1F5F9)),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.5,
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
  ),
  cardTheme: CardThemeData(
    color: rxDarkSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: rxBlue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      elevation: 4,
      shadowColor: rxBlue.withOpacity(0.4),
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.white70),
  dividerTheme: const DividerThemeData(color: Colors.white12),
);

// 🌟 Immortal Theme (Dark Only for simplicity, but accessible)
final ThemeData darkImmortalTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: immortalGold,
  scaffoldBackgroundColor: const Color(0xFF0C0A09), // Very dark warm grey
  colorScheme: ColorScheme.fromSeed(
    seedColor: immortalGold,
    brightness: Brightness.dark,
    primary: immortalGold,
    secondary: const Color(0xFFFACC15),
    surface: immortalDarkSurface,
    onSurface: const Color(0xFFFFF7ED),
  ),
  textTheme: _buildGodTierTypography(
      ThemeData.dark().textTheme, const Color(0xFFFFF7ED)),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: immortalGold,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: immortalGold,
      letterSpacing: 1.0,
    ),
    iconTheme: const IconThemeData(color: immortalGold),
  ),
  cardTheme: CardThemeData(
    color: immortalDarkSurface,
    elevation: 8,
    shadowColor: immortalGold.withOpacity(0.2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: immortalGold.withOpacity(0.3), width: 1),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: immortalGold,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      elevation: 6,
      shadowColor: immortalGold.withOpacity(0.5),
    ),
  ),
);

// Keeping Light Immortal simplified as a variation of Porcelain with Gold accents
final ThemeData lightImmortalTheme = lightTheme.copyWith(
  colorScheme: lightTheme.colorScheme.copyWith(
    primary: const Color(0xFFB45309), // Bronze/Gold
    secondary: const Color(0xFFD97706),
  ),
  primaryColor: const Color(0xFFB45309),
  appBarTheme: lightTheme.appBarTheme.copyWith(
    foregroundColor: const Color(0xFF78350F),
    titleTextStyle: GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF78350F),
      letterSpacing: 1.0,
    ),
  ),
);
