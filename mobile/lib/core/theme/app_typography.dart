import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Editorial Typography System featuring Tabular Figures for monetary values
class AppTypography {
  AppTypography._();

  static const List<FontFeature> tabularFigures = [FontFeature.tabularFigures()];

  // Base font style
  static TextStyle get base => GoogleFonts.plusJakartaSansTextTheme().bodyMedium!;

  // 1. Balance Display (Prominent cockpit number)
  static TextStyle balance(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.plusJakartaSans(
      fontSize: 34.0,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
      fontFeatures: tabularFigures,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
    );
  }

  // 2. Heading 1
  static TextStyle h1(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.plusJakartaSans(
      fontSize: 22.0,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.4,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
    );
  }

  // 3. Heading 2
  static TextStyle h2(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.plusJakartaSans(
      fontSize: 17.0,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
    );
  }

  // 4. Section Eyebrow (Editorial uppercase small heading)
  static TextStyle sectionEyebrow(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.plusJakartaSans(
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: color ?? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
    );
  }

  // 5. Body Default
  static TextStyle body(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.plusJakartaSans(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
    );
  }

  // 6. Body Muted / Secondary
  static TextStyle bodyMuted(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.plusJakartaSans(
      fontSize: 13.0,
      fontWeight: FontWeight.w400,
      color: color ?? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
    );
  }

  // 7. Amount Text (For list items and receipts)
  static TextStyle amount(BuildContext context, {Color? color, double fontSize = 16.0}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      fontFeatures: tabularFigures,
      color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
    );
  }

  // 8. Caption & Metadata
  static TextStyle caption(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.plusJakartaSans(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      color: color ?? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
    );
  }
}
