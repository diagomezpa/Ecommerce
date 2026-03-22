/// PriceFormatter - Helper for formatting price display values
///
/// This helper centralizes all price formatting logic that was
/// previously scattered across UI components. Ensures consistent
/// price display formatting throughout the application.
///
/// **Features:**
/// - Consistent price formatting with currency symbol
/// - Decimal place standardization
/// - Reusable across all UI components
/// - Easy to test and maintain
/// - Localization ready for future enhancements
class PriceFormatter {
  // Currency symbol - configurable for future localization
  static const String _currencySymbol = '\$';
  static const int _decimalPlaces = 2;

  /// Format price with currency symbol and standard decimal places
  /// 
  /// Returns formatted string like "$29.99"
  static String format(double price) {
    return '$_currencySymbol${price.toStringAsFixed(_decimalPlaces)}';
  }

  /// Format price for display with optional discount
  /// 
  /// Shows original price and discounted price when applicable
  static String formatWithDiscount(double originalPrice, double? discountedPrice) {
    if (discountedPrice != null && discountedPrice < originalPrice) {
      return '${format(discountedPrice)} (was ${format(originalPrice)})';
    }
    return format(originalPrice);
  }

  /// Format price range for products with variable pricing
  /// 
  /// Returns formatted string like "$15.99 - $49.99"
  static String formatRange(double minPrice, double maxPrice) {
    if (minPrice == maxPrice) {
      return format(minPrice);
    }
    return '${format(minPrice)} - ${format(maxPrice)}';
  }

  /// Check if price is valid for display
  /// 
  /// Helper method for validation before formatting
  static bool isValidPrice(double? price) {
    return price != null && price >= 0;
  }

  /// Format price with custom currency symbol
  /// 
  /// Useful for multi-currency support in future
  static String formatWithCurrency(double price, String currencySymbol) {
    return '$currencySymbol${price.toStringAsFixed(_decimalPlaces)}';
  }
}