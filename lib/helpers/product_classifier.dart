import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';

/// ProductClassifier - Business logic for classifying products into special categories
///
/// This helper centralizes all product classification logic following
/// business rules without mixing concerns with UI components.
/// 
/// **Features:**
/// - Featured products classification (high rating)
/// - Promotional products classification (low price)
/// - Reusable across multiple components
/// - Easy to test and maintain
/// - Clear business rules separation
class ProductClassifier {
  // Business rule constants
  static const double _featuredRatingThreshold = 4.0;
  static const double _promotionalPriceThreshold = 50.0;

  /// Get featured products based on high rating
  /// 
  /// Business rule: Products with rating >= 4.0 are considered featured
  static List<Product> getFeaturedProducts(List<Product> products) {
    return products
        .where((product) => _isFeaturedProduct(product))
        .toList();
  }

  /// Get promotional products based on low price
  /// 
  /// Business rule: Products with price < $50 are considered promotional
  static List<Product> getPromotionalProducts(List<Product> products) {
    return products
        .where((product) => _isPromotionalProduct(product))
        .toList();
  }

  /// Get both featured and promotional products in one call
  /// 
  /// Returns a map with both classifications for efficiency
  static ProductClassificationResult classifyProducts(List<Product> products) {
    final featured = <Product>[];
    final promotional = <Product>[];

    for (final product in products) {
      if (_isFeaturedProduct(product)) {
        featured.add(product);
      }
      if (_isPromotionalProduct(product)) {
        promotional.add(product);
      }
    }

    return ProductClassificationResult(
      featured: featured,
      promotional: promotional,
    );
  }

  /// Check if a product qualifies as featured
  /// 
  /// Private business rule implementation
  static bool _isFeaturedProduct(Product product) {
    final rating = product.rating.rate;
    return rating >= _featuredRatingThreshold;
  }

  /// Check if a product qualifies as promotional
  /// 
  /// Private business rule implementation
  static bool _isPromotionalProduct(Product product) {
    return product.price < _promotionalPriceThreshold;
  }

  /// Get classification summary for analytics/debugging
  /// 
  /// Useful for understanding product distribution
  static ProductClassificationSummary getClassificationSummary(List<Product> products) {
    final result = classifyProducts(products);
    
    return ProductClassificationSummary(
      totalProducts: products.length,
      featuredCount: result.featured.length,
      promotionalCount: result.promotional.length,
      bothFeaturedAndPromotionalCount: _countProductsInBothCategories(products),
      featuredPercentage: products.isEmpty ? 0 : (result.featured.length / products.length * 100),
      promotionalPercentage: products.isEmpty ? 0 : (result.promotional.length / products.length * 100),
    );
  }

  /// Count products that are both featured and promotional
  /// 
  /// Helper for analytics
  static int _countProductsInBothCategories(List<Product> products) {
    return products
        .where((product) => _isFeaturedProduct(product) && _isPromotionalProduct(product))
        .length;
  }

  /// Get products that are both featured AND promotional
  /// 
  /// Special category for products that meet both criteria
  static List<Product> getFeaturedPromotionalProducts(List<Product> products) {
    return products
        .where((product) => _isFeaturedProduct(product) && _isPromotionalProduct(product))
        .toList();
  }
}

/// ProductClassificationResult - Result wrapper for product classification
/// 
/// Encapsulates both featured and promotional product lists
class ProductClassificationResult {
  final List<Product> featured;
  final List<Product> promotional;

  const ProductClassificationResult({
    required this.featured,
    required this.promotional,
  });

  /// Check if there are any featured products
  bool get hasFeaturedProducts => featured.isNotEmpty;

  /// Check if there are any promotional products
  bool get hasPromotionalProducts => promotional.isNotEmpty;

  /// Get total unique products across both categories
  int get totalUniqueProducts {
    final allIds = <int>{};
    for (final product in featured) {
      allIds.add(product.id);
    }
    for (final product in promotional) {
      allIds.add(product.id);
    }
    return allIds.length;
  }
}

/// ProductClassificationSummary - Analytics/summary data for classifications
/// 
/// Useful for debugging and understanding product distribution
class ProductClassificationSummary {
  final int totalProducts;
  final int featuredCount;
  final int promotionalCount;
  final int bothFeaturedAndPromotionalCount;
  final double featuredPercentage;
  final double promotionalPercentage;

  const ProductClassificationSummary({
    required this.totalProducts,
    required this.featuredCount,
    required this.promotionalCount,
    required this.bothFeaturedAndPromotionalCount,
    required this.featuredPercentage,
    required this.promotionalPercentage,
  });

  /// Get formatted summary text for UI display
  String get formattedSummary {
    return 'Total: $totalProducts | Featured: $featuredCount (${featuredPercentage.toStringAsFixed(1)}%) | '
           'Promotional: $promotionalCount (${promotionalPercentage.toStringAsFixed(1)}%) | '
           'Both: $bothFeaturedAndPromotionalCount';
  }
}