import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const pink   = 'pink';
  static const dark   = 'dark';
  static const purple = 'purple';
  static const white  = 'white';
  static const gold   = 'gold';   // ← جديد
  static const teal   = 'teal';   // ← جديد

  // خط عربي Cairo لكل الثيمات
  static TextTheme get _arabicText =>
      GoogleFonts.cairoTextTheme().copyWith(
        displayLarge:  GoogleFonts.cairo(fontWeight: FontWeight.w700),
        headlineLarge: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        headlineMedium:GoogleFonts.cairo(fontWeight: FontWeight.w700),
        titleLarge:    GoogleFonts.cairo(fontWeight: FontWeight.w700),
        titleMedium:   GoogleFonts.cairo(fontWeight: FontWeight.w600),
        bodyLarge:     GoogleFonts.cairo(),
        bodyMedium:    GoogleFonts.cairo(),
        labelLarge:    GoogleFonts.cairo(fontWeight: FontWeight.w600),
      );

  static ThemeData themeFor(String name) {
    final (seed, brightness, bg) = switch (name) {
      dark   => (const Color(0xFF8E3A59), Brightness.dark,  const Color(0xFF120914)),
      purple => (const Color(0xFF7E57C2), Brightness.dark,  const Color(0xFF0D0B1A)),
      gold   => (const Color(0xFFB8860B), Brightness.light, const Color(0xFFFFFBF0)),
      teal   => (const Color(0xFF00796B), Brightness.light, const Color(0xFFF0FAFA)),
      white  => (const Color(0xFFD86B8C), Brightness.light, Colors.white),
      _      => (const Color(0xFFD86B8C), Brightness.light, const Color(0xFFFFF1F6)),
    };

    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

    return ThemeData(
      useMaterial3:  true,
      colorScheme:   scheme,
      textTheme:     _arabicText.apply(
        bodyColor:    scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: scheme.surfaceContainerHighest.withOpacity(0.72),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        backgroundColor: scheme.surface.withOpacity(0.95),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 11),
      ),
    );
  }
}
