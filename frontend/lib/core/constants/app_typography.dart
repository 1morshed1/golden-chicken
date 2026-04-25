import 'package:flutter/material.dart';
import 'package:golden_chicken/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextStyle _base(String locale) {
    return locale == 'bn'
        ? GoogleFonts.hindSiliguri()
        : GoogleFonts.plusJakartaSans();
  }

  static TextTheme textTheme(String locale) {
    final base = _base(locale);
    return TextTheme(
      headlineLarge: base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.textPrimary,
      ),
      headlineMedium: base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppColors.textPrimary,
      ),
      headlineSmall: base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.textPrimary,
      ),
      bodyLarge: base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimary,
      ),
      bodyMedium: base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textSecondary,
      ),
      bodySmall: base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textTertiary,
      ),
      labelLarge: base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1,
        color: Colors.white,
      ),
      labelMedium: base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1,
        color: AppColors.textSecondary,
      ),
      labelSmall: base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1,
        color: AppColors.textTertiary,
      ),
    );
  }
}
