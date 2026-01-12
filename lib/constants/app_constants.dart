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
  static const Duration snackbar = Duration(seconds: 4);
  static const Duration toast = Duration(seconds: 2);
}

/// Business logic constants
class BusinessConstants {
  BusinessConstants._();

  // Tax
  static const double defaultTaxRate = 18.0; // GST rate in India
  static const double minTaxRate = 0.0;
  static const double maxTaxRate = 100.0;

  // Currency
  static const String defaultCurrency = 'INR';
  static const String defaultInvoicePrefix = 'INV';

  // Notifications
  static const int maxNotificationDisplay = 99;

  // Validation
  static const int minPasswordLength = 6;
  static const int minPhoneLength = 7;
  static const int maxPhoneLength = 15;
  static const int minStockAlert = 5;
}

/// Thermal receipt dimensions
class ReceiptDimensions {
  ReceiptDimensions._();

  static const double thermal58mm = 300.0; // ~58mm thermal paper width
  static const double thermal80mm = 400.0; // ~80mm thermal paper width
}

/// Regex patterns for validation
class ValidationPatterns {
  ValidationPatterns._();

  static final RegExp email = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  static final RegExp phone = RegExp(
    r'^[0-9+\-\s()]{7,15}$',
  );

  static final RegExp alphanumeric = RegExp(
    r'^[a-zA-Z0-9\s]+$',
  );

  static final RegExp numeric = RegExp(
    r'^[0-9]+$',
  );

  static final RegExp gst = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
  );
}

/// Opacity constants for consistent transparency levels
class OpacityConstants {
  OpacityConstants._();

  static const double veryLight = 0.05;
  static const double light = 0.1;
  static const double mild = 0.15;
  static const double medium = 0.2;
  static const double mediumHigh = 0.3;
  static const double high = 0.4;
  static const double disabled = 0.38;
  static const double secondary = 0.54;
  static const double tertiary = 0.6;
  static const double emphasis = 0.87;
}
