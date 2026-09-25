import 'package:flutter/material.dart';

/// Editorial Minimalist Color System
class AppColors {
  AppColors._();

  // --- Light Theme Colors ---
  static const Color lightBackground = Color(0xFFFBFBF9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF4F4F0);
  static const Color lightTextPrimary = Color(0xFF131417);
  static const Color lightTextSecondary = Color(0xFF63656D);
  static const Color lightTextMuted = Color(0xFF989AA2);
  static const Color lightBorder = Color(0xFFE5E5DF);
  static const Color lightBorderSubtle = Color(0xFFEFEFEA);

  // --- Dark Theme Colors ---
  static const Color darkBackground = Color(0xFF0E0F12);
  static const Color darkSurface = Color(0xFF16171C);
  static const Color darkSurfaceSubtle = Color(0xFF1F2026);
  static const Color darkTextPrimary = Color(0xFFF5F5F3);
  static const Color darkTextSecondary = Color(0xFF9B9CA4);
  static const Color darkTextMuted = Color(0xFF65666F);
  static const Color darkBorder = Color(0xFF26272F);
  static const Color darkBorderSubtle = Color(0xFF1B1C22);

  // --- Signature Accent (Deep Cobalt) ---
  static const Color accentLight = Color(0xFF1E3A8A);
  static const Color accentDark = Color(0xFF3B82F6);

  // --- Semantic Financial Categories ---
  static const Color categoryNeeds = Color(0xFF0F766E); // Teal / Essential
  static const Color categoryNeedsDark = Color(0xFF2DD4BF);

  static const Color categoryWants = Color(0xFFC2410C); // Warm Rust / Lifestyle
  static const Color categoryWantsDark = Color(0xFFFB923C);

  static const Color categorySimpanan = Color(0xFF1D4ED8); // Solid Blue / Savings
  static const Color categorySimpananDark = Color(0xFF60A5FA);

  static const Color categoryInvestasi = Color(0xFF6D28D9); // Deep Violet / Growth
  static const Color categoryInvestasiDark = Color(0xFFA78BFA);

  // --- Indicators & Feedback ---
  static const Color positive = Color(0xFF15803D); // Green
  static const Color positiveDark = Color(0xFF4ADE80);

  static const Color negative = Color(0xFFB91C1C); // Crimson
  static const Color negativeDark = Color(0xFFF87171);

  static const Color warning = Color(0xFFB45309);
  static const Color warningDark = Color(0xFFFBBF24);

  /// Helper to get category color depending on brightness
  static Color getCategoryColor(String category, {required bool isDark}) {
    switch (category) {
      case 'Needs':
        return isDark ? categoryNeedsDark : categoryNeeds;
      case 'Wants':
        return isDark ? categoryWantsDark : categoryWants;
      case 'Simpanan':
        return isDark ? categorySimpananDark : categorySimpanan;
      case 'Investasi':
        return isDark ? categoryInvestasiDark : categoryInvestasi;
      default:
        return isDark ? darkTextSecondary : lightTextSecondary;
    }
  }

  /// Background tint for category badges
  static Color getCategoryBg(String category, {required bool isDark}) {
    final color = getCategoryColor(category, isDark: isDark);
    return color.withValues(alpha: isDark ? 0.16 : 0.08);
  }
}
