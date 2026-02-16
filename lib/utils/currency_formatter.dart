/// Currency formatting utilities for consistent currency display
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
