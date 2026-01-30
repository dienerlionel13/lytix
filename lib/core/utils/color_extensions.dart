import 'package:flutter/material.dart';

/// Color extensions for Flutter 3.32+ compatibility
/// Replaces deprecated withOpacity with withValues
extension ColorExtensions on Color {
  /// Creates a new color with the given alpha value (0.0 to 1.0)
  /// Compatible replacement for deprecated withOpacity
  Color withAlpha8(double opacity) {
    return withValues(alpha: opacity);
  }
}

/// Predefined semi-transparent colors for common use cases
class SemiTransparent {
  SemiTransparent._();

  // Black variations
  static const Color black05 = Color(0x0D000000); // 5%
  static const Color black10 = Color(0x1A000000); // 10%
  static const Color black20 = Color(0x33000000); // 20%
  static const Color black30 = Color(0x4D000000); // 30%
  static const Color black40 = Color(0x66000000); // 40%
  static const Color black50 = Color(0x80000000); // 50%
  static const Color black60 = Color(0x99000000); // 60%
  static const Color black70 = Color(0xB3000000); // 70%
  static const Color black80 = Color(0xCC000000); // 80%
  static const Color black90 = Color(0xE6000000); // 90%

  // White variations
  static const Color white05 = Color(0x0DFFFFFF); // 5%
  static const Color white10 = Color(0x1AFFFFFF); // 10%
  static const Color white20 = Color(0x33FFFFFF); // 20%
  static const Color white30 = Color(0x4DFFFFFF); // 30%
  static const Color white40 = Color(0x66FFFFFF); // 40%
  static const Color white50 = Color(0x80FFFFFF); // 50%
  static const Color white60 = Color(0x99FFFFFF); // 60%
  static const Color white70 = Color(0xB3FFFFFF); // 70%
  static const Color white80 = Color(0xCCFFFFFF); // 80%
  static const Color white90 = Color(0xE6FFFFFF); // 90%
}
