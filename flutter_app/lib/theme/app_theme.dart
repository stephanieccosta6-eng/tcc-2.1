import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFFFAF7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFFFF1F2);

  // Paleta Principal Rose Skincare (alto contraste)
  static const Color primary = Color(0xFFBE185D);
  static const Color primaryDark = Color(0xFF831843);
  static const Color primaryLight = Color(0xFFE11D48);
  static const Color primarySoft = Color(0xFFFCE7F3);

  // Paleta Complementar Lavanda / Berry suave para Planos (evita visual P&B)
  static const Color planSecondaryBg = Color(0xFFF5F3FF);
  static const Color planSecondaryBorder = Color(0xFFC4B5FD);
  static const Color planSecondaryAccent = Color(0xFF6D28D9);

  // Contraste corrigido para avisos em amarelo/âmbar (fundo creme quente + texto marrom escuro)
  static const Color amberCardBg = Color(0xFFFEF3C7);
  static const Color amberCardBorder = Color(0xFFD97706);
  static const Color amberCardText = Color(0xFF78350F);

  // GlowFridge IoT
  static const Color fridgeDark = Color(0xFF1E293B);
  static const Color fridgeDeep = Color(0xFF0F172A);
  static const Color iceAccent = Color(0xFF38BDF8);

  // Textos & Bordas
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF334155);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF059669);
  static const Color error = Color(0xFFDC2626);
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseText = GoogleFonts.plusJakartaSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      textTheme: baseText.copyWith(
        headlineMedium: baseText.headlineMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.4,
        ),
        headlineSmall: baseText.headlineSmall?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        titleLarge: baseText.titleLarge?.copyWith(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: baseText.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: baseText.bodyLarge?.copyWith(
          fontSize: 16.5,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          fontSize: 15.5,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15.5),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 15.5, fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF881337).withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}
