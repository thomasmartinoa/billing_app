import 'package:flutter/material.dart';

/// Application-wide color palette for dark theme
class AppColorsDark {
  // Prevent instantiation
  AppColorsDark._();

  // Primary Colors
  static const Color accent = Color(0xFF00C59E);
  static const Color primary = Color(0xFF17F1C5);

  // Background Colors
  static const Color background = Color(0xFF050608);
  static const Color surface = Color(0x14181818);
  static const Color surfaceOpaque = Color(0xFF1A1A1A);
  static const Color cardBackground = Color(0xFF1B1E22);

  // Border Colors
  static const Color border = Color(0xFF12332D);
  static const Color borderLight = Color(0xFF252A30);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textInverse = Colors.black;

  // Status Colors
  static const Color success = Color(0xFF00C59E);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF64B5F6);

  // Drawer Colors
  static const Color drawerHeader = Color(0xFF0A0A0A);
  static const Color drawerBackground = Color(0xFF0A0A0A);
}

/// Application-wide color palette for light theme
class AppColorsLight {
  // Prevent instantiation
  AppColorsLight._();

  // Primary Colors
  static const Color accent = Color(0xFF00A583);
  static const Color primary = Color(0xFF00C59E);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceOpaque = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textInverse = Colors.white;

  // Status Colors
  static const Color success = Color(0xFF00A583);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Drawer Colors
  static const Color drawerHeader = Color(0xFF00C59E);
  static const Color drawerBackground = Color(0xFFFFFFFF);
}

/// Legacy AppColors for backward compatibility - uses dark theme colors
class AppColors {
  AppColors._();

  static const Color accent = AppColorsDark.accent;
  static const Color primary = AppColorsDark.primary;
  static const Color background = AppColorsDark.background;
  static const Color surface = AppColorsDark.surface;
  static const Color surfaceOpaque = AppColorsDark.surfaceOpaque;
  static const Color cardBackground = AppColorsDark.cardBackground;
  static const Color border = AppColorsDark.border;
  static const Color borderLight = AppColorsDark.borderLight;
  static const Color textWhite = AppColorsDark.textPrimary;
  static const Color textGray = AppColorsDark.textSecondary;
  static const Color textBlack = AppColorsDark.textInverse;
  static const Color success = AppColorsDark.success;
  static const Color error = AppColorsDark.error;
  static const Color warning = AppColorsDark.warning;
  static const Color info = AppColorsDark.info;
  static const Color drawerHeader = AppColorsDark.drawerHeader;
  static const Color drawerBackground = AppColorsDark.drawerBackground;
}

/// Application theme configuration
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColorsDark.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColorsDark.primary,
        brightness: Brightness.dark,
        primary: AppColorsDark.primary,
        secondary: AppColorsDark.accent,
        surface: AppColorsDark.surface,
        error: AppColorsDark.error,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsDark.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColorsDark.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColorsDark.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColorsDark.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColorsDark.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColorsDark.error, width: 2),
        ),
        labelStyle: TextStyle(fontSize: 13, color: AppColorsDark.textSecondary),
        hintStyle: TextStyle(color: AppColorsDark.textTertiary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColorsDark.accent),
        titleTextStyle: TextStyle(
          color: AppColorsDark.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColorsDark.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsDark.accent,
          foregroundColor: AppColorsDark.textInverse,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsDark.accent,
          side: const BorderSide(color: AppColorsDark.accent),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsDark.accent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColorsDark.accent,
        foregroundColor: AppColorsDark.textInverse,
        elevation: 4,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColorsDark.accent,
        circularTrackColor: AppColorsDark.surface,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColorsDark.border,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColorsDark.textPrimary,
        size: 24,
      ),

      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColorsDark.drawerBackground,
      ),

      // ListTile Theme
      listTileTheme: const ListTileThemeData(
        textColor: AppColorsDark.textPrimary,
        iconColor: AppColorsDark.textPrimary,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColorsDark.surfaceOpaque,
        selectedItemColor: AppColorsDark.accent,
        unselectedItemColor: AppColorsDark.textSecondary,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColorsDark.surfaceOpaque,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsDark.accent;
          }
          return null;
        }),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsDark.accent;
          }
          return null;
        }),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsDark.accent;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsDark.accent.withOpacity(0.5);
          }
          return null;
        }),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: AppColorsLight.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColorsLight.primary,
        brightness: Brightness.light,
        primary: AppColorsLight.primary,
        secondary: AppColorsLight.accent,
        surface: AppColorsLight.surface,
        error: AppColorsLight.error,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsLight.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColorsLight.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColorsLight.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColorsLight.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColorsLight.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColorsLight.error, width: 2),
        ),
        labelStyle:
            TextStyle(fontSize: 13, color: AppColorsLight.textSecondary),
        hintStyle: TextStyle(color: AppColorsLight.textTertiary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColorsLight.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColorsLight.textInverse),
        titleTextStyle: TextStyle(
          color: AppColorsLight.textInverse,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColorsLight.cardBackground,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColorsLight.border, width: 1),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsLight.accent,
          foregroundColor: AppColorsLight.textInverse,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsLight.accent,
          side: const BorderSide(color: AppColorsLight.accent),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsLight.accent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColorsLight.accent,
        foregroundColor: AppColorsLight.textInverse,
        elevation: 4,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColorsLight.accent,
        circularTrackColor: AppColorsLight.borderLight,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColorsLight.border,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColorsLight.textPrimary,
        size: 24,
      ),

      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColorsLight.drawerBackground,
      ),

      // ListTile Theme
      listTileTheme: const ListTileThemeData(
        textColor: AppColorsLight.textPrimary,
        iconColor: AppColorsLight.textSecondary,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColorsLight.surface,
        selectedItemColor: AppColorsLight.accent,
        unselectedItemColor: AppColorsLight.textSecondary,
        elevation: 8,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColorsLight.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsLight.accent;
          }
          return null;
        }),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsLight.accent;
          }
          return null;
        }),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsLight.accent;
          }
          return Colors.grey[400];
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsLight.accent.withOpacity(0.5);
          }
          return Colors.grey[300];
        }),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColorsLight.textPrimary,
        contentTextStyle: const TextStyle(color: AppColorsLight.textInverse),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Common text styles used across the app
/// These return theme-aware styles that adapt to light/dark mode
class AppTextStyles {
  AppTextStyles._();

  // Headings - use with Theme.of(context)
  static TextStyle h1(BuildContext context) => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle h2(BuildContext context) => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle h3(BuildContext context) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle h4(BuildContext context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  // Body Text
  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurface,
      );

  // Labels
  static TextStyle label(BuildContext context) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      );

  // Button Text
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // Caption
  static TextStyle caption(BuildContext context) => TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      );

  // Accent Text
  static TextStyle accent(BuildContext context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.secondary,
      );
}

/// Common spacing values
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Common border radius values
class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;

  static BorderRadius get small => BorderRadius.circular(sm);
  static BorderRadius get medium => BorderRadius.circular(md);
  static BorderRadius get large => BorderRadius.circular(lg);
  static BorderRadius get extraLarge => BorderRadius.circular(xl);
}
