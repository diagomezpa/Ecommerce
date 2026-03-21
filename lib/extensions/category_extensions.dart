import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';

/// CategoryExtensions - Extensions for Category enum formatting
///
/// This extension provides formatted display names for Category enum values.
/// Extracted from UI layers where the same formatting logic was duplicated
/// across multiple pages.
///
/// **Features:**
/// - Consistent category name formatting
/// - Centralized transformation logic
/// - Easy to maintain and update
/// - Eliminates code duplication
extension CategoryExtensions on Category {
  /// Get formatted display name for category
  /// 
  /// Converts enum values to user-friendly display strings
  String get displayName {
    switch (this) {
      case Category.ELECTRONICS:
        return 'Electronics';
      case Category.JEWELERY:
        return 'Jewelry';
      case Category.MENS_CLOTHING:
        return "Men's Clothing";
      case Category.WOMENS_CLOTHING:
        return "Women's Clothing";
    }
  }

  /// Get category icon for UI display
  /// 
  /// Maps categories to appropriate icons
  int get iconCodePoint {
    switch (this) {
      case Category.ELECTRONICS:
        return 0xe1ca; // Icons.computer
      case Category.JEWELERY:
        return 0xe22e; // Icons.diamond
      case Category.MENS_CLOTHING:
        return 0xe4c6; // Icons.man
      case Category.WOMENS_CLOTHING:
        return 0xe55c; // Icons.woman
    }
  }

  /// Get category color for UI styling
  /// 
  /// Maps categories to theme colors
  String get colorHex {
    switch (this) {
      case Category.ELECTRONICS:
        return '#2196F3'; // Blue
      case Category.JEWELERY:
        return '#FF9800'; // Orange  
      case Category.MENS_CLOTHING:
        return '#4CAF50'; // Green
      case Category.WOMENS_CLOTHING:
        return '#E91E63'; // Pink
    }
  }
}