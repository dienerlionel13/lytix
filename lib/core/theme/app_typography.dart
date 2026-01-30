import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App Typography using Google Fonts
class AppTypography {
  AppTypography._();

  // Font Family
  static String get fontFamily => GoogleFonts.poppins().fontFamily!;

  // Headings
  static TextStyle get h1 => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get h2 => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get h3 => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get h4 => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get h5 => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get h6 => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Text
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Labels
  static TextStyle get labelLarge => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  // Special Styles
  static TextStyle get currency => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get currencySmall => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );
}
