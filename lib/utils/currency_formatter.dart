/// Currency formatting utilities for consistent currency display
library;

class CurrencyConstants {
  CurrencyConstants._();

  // Currency symbols
  static const String rupeeSymbol = '₹';
  static const String dollarSymbol = '\$';
  static const String euroSymbol = '€';
  static const String poundSymbol = '£';

  // Currency codes
  static const String inr = 'INR';
  static const String usd = 'USD';
  static const String eur = 'EUR';
  static const String gbp = 'GBP';

  // Default currency
  static const String defaultCurrency = inr;
  static const String defaultSymbol = rupeeSymbol;
}

/// Currency formatter utility for consistent formatting throughout the app
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format amount with 2 decimal places
  /// 
  /// Example: `format(1234.5)` returns `"₹1,234.50"`
  static String format(
    double amount, {
    String? currencySymbol,
    bool showDecimals = true,
  }) {
    final symbol = currencySymbol ?? CurrencyConstants.defaultSymbol;
    final formatted = showDecimals
        ? amount.toStringAsFixed(2)
        : amount.toStringAsFixed(0);
    
    // Add thousand separators
    return '$symbol${_addThousandSeparators(formatted)}';
  }

  /// Format amount without decimal places (compact)
  /// 
  /// Example: `formatCompact(1234.5)` returns `"₹1,234"`
  static String formatCompact(double amount, {String? currencySymbol}) {
    return format(amount, currencySymbol: currencySymbol, showDecimals: false);
  }

  /// Format for display in tables/lists (right-aligned)
  /// 
  /// Example: `formatForTable(1234.5)` returns `"1,234.50"` (no symbol)
  static String formatForTable(double amount, {bool showDecimals = true}) {
    final formatted = showDecimals
        ? amount.toStringAsFixed(2)
        : amount.toStringAsFixed(0);
    return _addThousandSeparators(formatted);
  }

  /// Format with currency code instead of symbol
  /// 
  /// Example: `formatWithCode(1234.5, 'INR')` returns `"INR 1,234.50"`
  static String formatWithCode(double amount, String currencyCode) {
    final formatted = amount.toStringAsFixed(2);
    return '$currencyCode ${_addThousandSeparators(formatted)}';
  }

  /// Format for thermal receipt printing
  /// 
  /// Example: `formatForReceipt(1234.5)` returns `"Rs.1234.50"`
  static String formatForReceipt(double amount) {
    return 'Rs.${amount.toStringAsFixed(2)}';
  }

  /// Get currency symbol from code
  static String getSymbolFromCode(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case CurrencyConstants.inr:
        return CurrencyConstants.rupeeSymbol;
      case CurrencyConstants.usd:
        return CurrencyConstants.dollarSymbol;
      case CurrencyConstants.eur:
        return CurrencyConstants.euroSymbol;
      case CurrencyConstants.gbp:
        return CurrencyConstants.poundSymbol;
      default:
        return CurrencyConstants.defaultSymbol;
    }
  }

  /// Add thousand separators to a number string
  static String _addThousandSeparators(String value) {
    final parts = value.split('.');
    final intPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Add commas every 3 digits from right
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
    }

    return buffer.toString() + decimalPart;
  }
}
