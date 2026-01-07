import 'package:flutter/material.dart';

/// Semantic colors for consistent status and state representation
/// These colors adapt to light/dark themes while maintaining semantic meaning
class AppSemanticColors {
  AppSemanticColors._(); // Private constructor to prevent instantiation

  // --- Success Colors (Paid, Completed, Positive) ---
  static const Color successLight = Color(0xFF4CAF50); // Green
  static const Color successDark = Color(0xFF66BB6A);
  static const Color successBackgroundLight = Color(0xFFE8F5E9);
  static const Color successBackgroundDark = Color(0xFF1B5E20);

  // --- Error Colors (Failed, Destructive, Negative) ---
  static const Color errorLight = Color(0xFFF44336); // Red
  static const Color errorDark = Color(0xFFEF5350);
  static const Color errorBackgroundLight = Color(0xFFFFEBEE);
  static const Color errorBackgroundDark = Color(0xFFB71C1C);

  // --- Warning Colors (Pending, Caution, Low Stock) ---
  static const Color warningLight = Color(0xFFFF9800); // Orange
  static const Color warningDark = Color(0xFFFFB74D);
  static const Color warningBackgroundLight = Color(0xFFFFF3E0);
  static const Color warningBackgroundDark = Color(0xFFE65100);

  // --- Info Colors (Information, Neutral Actions) ---
  static const Color infoLight = Color(0xFF2196F3); // Blue
  static const Color infoDark = Color(0xFF42A5F5);
  static const Color infoBackgroundLight = Color(0xFFE3F2FD);
  static const Color infoBackgroundDark = Color(0xFF0D47A1);

  /// Get success color based on theme brightness
  static Color success(Brightness brightness) {
    return brightness == Brightness.light ? successLight : successDark;
  }

  /// Get error color based on theme brightness
  static Color error(Brightness brightness) {
    return brightness == Brightness.light ? errorLight : errorDark;
  }

  /// Get warning color based on theme brightness
  static Color warning(Brightness brightness) {
    return brightness == Brightness.light ? warningLight : warningDark;
  }

  /// Get info color based on theme brightness
  static Color info(Brightness brightness) {
    return brightness == Brightness.light ? infoLight : infoDark;
  }

  /// Get success background color based on theme brightness
  static Color successBackground(Brightness brightness) {
    return brightness == Brightness.light
        ? successBackgroundLight
        : successBackgroundDark;
  }

  /// Get error background color based on theme brightness
  static Color errorBackground(Brightness brightness) {
    return brightness == Brightness.light
        ? errorBackgroundLight
        : errorBackgroundDark;
  }

  /// Get warning background color based on theme brightness
  static Color warningBackground(Brightness brightness) {
    return brightness == Brightness.light
        ? warningBackgroundLight
        : warningBackgroundDark;
  }

  /// Get info background color based on theme brightness
  static Color infoBackground(Brightness brightness) {
    return brightness == Brightness.light
        ? infoBackgroundLight
        : infoBackgroundDark;
  }
}
