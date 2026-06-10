// lib/utils/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── GOOGLE BRANDING COLOR PALETTE ───
  static const Color primary = Color(0xFF1A73E8); // Biru Google Asli
  static const Color primaryDark = Color(0xFF1557B0); // Biru Google Agak Gelap
  static const Color primaryLight = Color(
    0xFFE8F0FE,
  ); // Biru Google Tipis / Pastel

  static const Color accent = Color(0xFFFBBC05); // Kuning Google
  static const Color accentGreen = Color(0xFF34A853); // Hijau Google
  static const Color accentRed = Color(0xFFEA4335); // Merah Google
  static const Color accentOrange = Color(0xFFFA7B17); // Oranye Google

  // Background dominan putih bersih dan abu-abu flat super tipis
  static const Color bgLight = Color(0xFFFFFFFF);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgCardLight = Color(
    0xFFF8F9FA,
  ); // Abu-abu terang Google (Surface)
  static const Color surface = Color(0xFFFFFFFF);

  // Tipografi Kontras & Rapi
  static const Color textPrimary = Color(0xFF202124); // Hitam pekat Google
  static const Color textSecondary = Color(
    0xFF5F6368,
  ); // Abu-abu text ikon / sub-judul
  static const Color textMuted = Color(0xFF80868B); // Abu-abu tipis pembantu

  static const Color divider = Color(0xFFF1F3F4); // Garis pembatas tipis halus
  static const Color inputFill = Color(
    0xFFFFFFFF,
  ); // Kolom input dasar putih bersih

  // ─── GRADIENTS SUBTLE ───
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4285F4), Color(0xFF1A73E8)],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.white, Color(0xFFF8F9FA)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Colors.white],
  );

  // ─── CONFIGURATION THEMEDATA (LIGHT MODE CLEAN) ───
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: accentRed,
      ),
      scaffoldBackgroundColor: bgLight,

      // ✅ TAMBAHAN UTAMA: Tema kursor & seleksi teks ala Google (Biar tidak ungu/pink lagi)
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: primary.withOpacity(0.2),
        selectionHandleColor: primary,
      ),

      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
            displayMedium: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
            headlineLarge: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
            headlineMedium: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
            titleLarge: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
            titleMedium: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
            bodyLarge: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textPrimary,
            ),
            bodyMedium: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: textSecondary,
            ),
            labelLarge: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: Color(0xFFDADCE0), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDADCE0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDADCE0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentRed, width: 1),
        ),
        hintStyle: GoogleFonts.poppins(color: textMuted, fontSize: 14),
        labelStyle: GoogleFonts.poppins(color: textSecondary, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFF1F3F4), width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgCardLight,
        selectedColor: primaryLight,
        labelStyle: GoogleFonts.poppins(fontSize: 12, color: textPrimary),
        secondaryLabelStyle: GoogleFonts.poppins(fontSize: 12, color: primary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: Color(0xFFDADCE0), width: 1),
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
    );
  }
}

// ─── STATUS SIGNAL COLORS ───
class StatusColors {
  static Color forStatus(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
      case 'pending':
        return AppTheme.accent;
      case 'disetujui':
      case 'lunas':
      case 'approved':
        return AppTheme.accentGreen;
      case 'ditolak':
      case 'rejected':
        return AppTheme.accentRed;
      case 'revisi':
        return AppTheme.accentOrange;
      case 'proses':
      case 'in_progress':
        return AppTheme.primary;
      default:
        return AppTheme.textMuted;
    }
  }

  static Color bgForStatus(String status) {
    return forStatus(status).withOpacity(0.08);
  }
}
