import 'package:flutter/material.dart';

/// App Color Palette - Premium Dark Theme
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF00D4AA);
  static const Color primaryDark = Color(0xFF00B894);
  static const Color primaryLight = Color(0xFF55EFC4);

  // Accent Colors
  static const Color accent = Color(0xFF6C5CE7);
  static const Color accentLight = Color(0xFFA29BFE);

  // Background Colors
  static const Color backgroundDark = Color(0xFF0D1B2A);
  static const Color backgroundMedium = Color(0xFF1B263B);
  static const Color backgroundLight = Color(0xFF415A77);

  // Surface Colors
  static const Color surfaceDark = Color(0xFF1E2D3D);
  static const Color surfaceLight = Color(0xFF2D3E50);

  // Status Colors
  static const Color success = Color(0xFF00D4AA);
  static const Color warning = Color(0xFFFFBE0B);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF74B9FF);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B7280);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF00D4AA),
    Color(0xFF6C5CE7),
    Color(0xFFFF6B6B),
    Color(0xFFFFBE0B),
    Color(0xFF74B9FF),
    Color(0xFFE17055),
    Color(0xFF00CEC9),
    Color(0xFFFD79A8),
  ];

  // Card Colors (for credit cards)
  static const List<Color> cardGradients = [
    Color(0xFF667eea),
    Color(0xFF764ba2),
    Color(0xFF6B8DD6),
    Color(0xFF8E37D7),
    Color(0xFF00D4AA),
    Color(0xFF00B894),
  ];

  // Glass Effect - Using const Color with alpha value
  static const Color glassWhite = Color(0x1AFFFFFF); // white with 0.1 opacity
  static const Color glassBorder = Color(0x1AFFFFFF); // white with 0.1 opacity

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundDark, backgroundMedium, backgroundMedium],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AFFFFFF), // white with 0.1 opacity
      Color(0x0DFFFFFF), // white with 0.05 opacity
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, Color(0xFFE55B5B)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warning, Color(0xFFFFD166)],
  );
}
