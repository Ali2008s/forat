// ═══════════════════════════════════════════════════════════════
//  ForaTV - App Constants & Theme (Dark + Light)
//  ألوان هادئة وجميلة – Calm & Beautiful Color Palette
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConstants {
  static const String appName = 'ForaTV';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // Firestore Collections
  static const String colServers = 'servers';
  static const String colSubscribers = 'subscribers';
  static const String colConfig = 'app_config';
  static const String docAppStatus = 'app_status';
  static const String docUpdateInfo = 'update_info';
  static const String docSettings = 'settings';
}

class AppColors {
  // Primary – Deep Purple / Violet
  static const Color primary = Color(0xFF7B27D3); // vibrant violet
  static const Color primaryDark = Color(0xFF4C1A91); // deep purple
  static const Color accent = Color(0xFFAB47BC); // lavender pink
  static const Color cyan = Color(0xFF00E5FF); // neon cyan
  static const Color neonPink = Color(0xFFFF4D8A); // neon pink

  // Dark Backgrounds – Deep Purple Night
  static const Color bgDark = Color(0xFF120D1C);
  static const Color bgCard = Color(0xFF1A1128);
  static const Color bgCardLight = Color(0xFF241838);
  static const Color surface = Color(0xFF1E1430);

  // Light Backgrounds
  static const Color bgLightPrimary = Color(0xFFF3EFFA);
  static const Color bgLightCard = Color(0xFFFFFFFF);
  static const Color bgLightSurface = Color(0xFFEDE7F6);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFFF4D4D);
  static const Color info = Color(0xFF7C4DFF);

  // Text
  static const Color textPrimary = Color(0xFFE8E0F0);
  static const Color textSecondary = Color(0xFFA893C2);
  static const Color textMuted = Color(0xFF6E5A8A);

  // Glass – subtle purple tint
  static const Color glassBorder = Color(0x2A7B27D3);
  static const Color glassBg = Color(0x127B27D3);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7B27D3), Color(0xFFAB47BC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF120D1C), Color(0xFF1A0E2E), Color(0xFF120D1C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1128), Color(0xFF1E1430)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonGradient = LinearGradient(
    colors: [Color(0xFFFF4D8A), Color(0xFF7B27D3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppThemes {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.alexandriaTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.alexandria(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.alexandria(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: GoogleFonts.alexandria(color: AppColors.textMuted),
        hintStyle: GoogleFonts.alexandria(color: AppColors.textMuted),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(
        0xFFF9F9FB,
      ), // Clean iOS-style light bg
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: Colors.white,
        error: AppColors.danger,
        onSurface: Colors.black87,
      ),
      textTheme: GoogleFonts.alexandriaTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        titleTextStyle: GoogleFonts.alexandria(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.alexandria(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: GoogleFonts.alexandria(color: Colors.grey.shade600),
        hintStyle: GoogleFonts.alexandria(color: Colors.grey.shade400),
      ),
    );
  }
}
