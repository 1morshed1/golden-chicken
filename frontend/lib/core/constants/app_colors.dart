import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary Orange (brand)
  static const Color primary = Color(0xFFFF6B00);
  static const Color primaryLight = Color(0xFFFF8C33);
  static const Color primaryDark = Color(0xFFE55D00);

  // Secondary / Dark navy
  static const Color secondary = Color(0xFF1A1A2E);
  static const Color secondaryLight = Color(0xFF2D2D44);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Severity
  static const Color severityCritical = Color(0xFFEF4444);
  static const Color severityHigh = Color(0xFFEF4444);
  static const Color severityMedium = Color(0xFFF59E0B);
  static const Color severityLow = Color(0xFF10B981);

  // Neutrals
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  // Chat bubbles
  static const Color userBubble = Color(0xFFFF6B00);
  static const Color aiBubble = Color(0xFFF1F5F9);

  // Bottom nav
  static const Color navBg = Color(0xFF1A1A2E);
  static const Color navActive = Color(0xFFFF6B00);
  static const Color navInactive = Color(0xFF94A3B8);

  // Loyalty
  static const Color loyaltyGradientStart = Color(0xFFFF6B00);
  static const Color loyaltyGradientEnd = Color(0xFFE55D00);

  // Splash
  static const Color splashBg = Color(0xFFFF6B00);

  // Dark mode
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF2D2D44);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
}
