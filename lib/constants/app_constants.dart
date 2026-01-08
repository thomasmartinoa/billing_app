/// Application-wide spacing, dimensions, and layout constants
library;

/// Spacing constants for consistent padding, margins, and gaps
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  // Vertical spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Common padding values
  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 12.0;
  static const double paddingLg = 16.0;
  static const double paddingXl = 20.0;
  static const double paddingXxl = 24.0;
}

/// Border radius constants for consistent rounded corners
class AppRadius {
  AppRadius._(); // Private constructor to prevent instantiation

  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 10.0;
  static const double lg = 12.0;
  static const double xl = 14.0;
  static const double xxl = 16.0;
  static const double xxxl = 20.0;
  static const double circular = 999.0; // For fully circular elements
}

/// Icon size constants
class AppIconSize {
  AppIconSize._();

  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 40.0;
  static const double xxl = 48.0;
}

/// Font size constants - use with AppTextStyles for best results
class AppFontSize {
  AppFontSize._();

  static const double xs = 10.0;
  static const double sm = 11.0;
  static const double md = 12.0;
  static const double base = 13.0;
  static const double lg = 14.0;
  static const double xl = 16.0;
  static const double xxl = 18.0;
  static const double xxxl = 20.0;
  static const double display1 = 24.0;
  static const double display2 = 28.0;
  static const double display3 = 38.0;
}

/// Elevation constants for consistent shadows
class AppElevation {
  AppElevation._();

  static const double none = 0.0;
  static const double sm = 1.0;
  static const double md = 2.0;
  static const double lg = 4.0;
  static const double xl = 8.0;
}

/// Animation duration constants
class AppDuration {
  AppDuration._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}
