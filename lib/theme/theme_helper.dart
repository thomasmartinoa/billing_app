import 'package:flutter/material.dart';
import 'package:billing_app/constants/semantic_colors.dart';

/// Theme-aware helper extensions and utilities
extension ThemeHelper on BuildContext {
  /// Get current theme colors
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Get primary text color
  Color get textPrimary => colors.onSurface;

  /// Get primary text color (alias for textPrimary)
  Color get primaryTextColor => colors.onSurface;

  /// Get secondary text color
  Color get textSecondary => colors.onSurface.withOpacity(0.6);

  /// Get secondary text color (alias for textSecondary)
  Color get secondaryTextColor => colors.onSurface.withOpacity(0.6);

  /// Get tertiary text color
  Color get textTertiary => colors.onSurface.withOpacity(0.4);

  /// Get white text color for primary text
  Color get textWhite => colors.onSurface;

  /// Get gray text color for secondary text
  Color get textGray => colors.onSurface.withOpacity(0.6);

  /// Get accent color
  Color get accent => colors.secondary;

  /// Get accent color (alias for accent)
  Color get accentColor => colors.secondary;

  /// Get card background color
  Color get cardColor => Theme.of(this).cardColor;

  /// Get scaffold background color
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;

  /// Get surface color
  Color get surfaceColor => colors.surface;

  /// Get border color
  Color get borderColor => colors.outline;

  /// Check if dark mode is active
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Check if light mode is active
  bool get isLightMode => Theme.of(this).brightness == Brightness.light;

  // --- Semantic Colors ---

  /// Get success color (green - for paid, completed, positive states)
  Color get successColor => AppSemanticColors.success(Theme.of(this).brightness);

  /// Get error color (red - for errors, destructive actions, negative states)
  Color get errorColor => AppSemanticColors.error(Theme.of(this).brightness);

  /// Get warning color (orange - for pending, caution, low stock)
  Color get warningColor => AppSemanticColors.warning(Theme.of(this).brightness);

  /// Get info color (blue - for information, neutral actions)
  Color get infoColor => AppSemanticColors.info(Theme.of(this).brightness);

  /// Get success background color with opacity
  Color get successBackground => AppSemanticColors.successBackground(Theme.of(this).brightness).withOpacity(0.1);

  /// Get error background color with opacity
  Color get errorBackground => AppSemanticColors.errorBackground(Theme.of(this).brightness).withOpacity(0.1);

  /// Get warning background color with opacity
  Color get warningBackground => AppSemanticColors.warningBackground(Theme.of(this).brightness).withOpacity(0.1);

  /// Get info background color with opacity
  Color get infoBackground => AppSemanticColors.infoBackground(Theme.of(this).brightness).withOpacity(0.1);
}

/// Theme-aware color utilities
class ThemeColors {
  /// Get appropriate text color based on theme
  static Color getTextColor(BuildContext context, {double opacity = 1.0}) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(opacity);
  }

  /// Get appropriate icon color based on theme
  static Color getIconColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  /// Get appropriate divider color based on theme
  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).dividerColor;
  }

  /// Get appropriate success color
  static Color getSuccessColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF00C59E) : const Color(0xFF00A583);
  }

  /// Get appropriate error color
  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  /// Get appropriate warning color
  static Color getWarningColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFFFB74D) : const Color(0xFFF57C00);
  }

  /// Get card elevation based on theme
  static double getCardElevation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? 2.0 : 1.0;
  }
}
