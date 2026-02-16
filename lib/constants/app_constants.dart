// Application-wide spacing, dimensions, and layout constants

/// Spacing constants for consistent padding, margins, and gaps
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 12.0;
  static const double paddingLg = 16.0;
  static const double paddingXl = 20.0;
  static const double paddingXxl = 24.0;
}

/// Border radius constants for consistent rounded corners
class AppRadius {
  AppRadius._();

  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 10.0;
  static const double lg = 12.0;
  static const double xl = 14.0;
  static const double xxl = 16.0;
  static const double xxxl = 20.0;
  static const double circular = 999.0;
}

/// Font size constants
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

  static const double defaultTaxRate = 18.0;
  static const double minTaxRate = 0.0;
  static const double maxTaxRate = 100.0;

  static const String defaultCurrency = 'INR';
  static const String defaultInvoicePrefix = 'INV';

  static const int maxNotificationDisplay = 99;

  static const int minPasswordLength = 6;
  static const int minPhoneLength = 7;
  static const int maxPhoneLength = 15;
  static const int minStockAlert = 5;
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
