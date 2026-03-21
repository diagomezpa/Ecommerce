import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import '../extensions/category_extensions.dart';

/// ProductFilterHelper - Business logic for product filtering operations
///
/// This helper centralizes all product filtering logic that was
/// previously scattered across UI components. Extracted to maintain
/// separation of concerns and ensure clean architecture principles.
///
/// **Features:**
/// - Category-based filtering
/// - Search text filtering
/// - Reusable across multiple components
/// - Easy to test and maintain
class ProductFilterHelper {
  /// Filter products by category
  /// 
  /// Returns all products if category is null, otherwise filters by specific category
  static List<Product> filterByCategory(
    List<Product> products,
    Category? selectedCategory,
  ) {
    if (selectedCategory == null) {
      return List.from(products);
    }
    
    return products
        .where((product) => product.category == selectedCategory)
        .toList();
  }

  /// Filter products by search text
  /// 
  /// Searches in product title and description (case-insensitive)
  static List<Product> filterBySearchText(
    List<Product> products,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) {
      return [];
    }
    
    final query = searchQuery.trim().toLowerCase();
    
    return products.where((product) {
      final titleMatch = product.title.toLowerCase().contains(query);
      final descriptionMatch = product.description.toLowerCase().contains(query);
      return titleMatch || descriptionMatch;
    }).toList();
  }

  /// Combined filter: category AND search text
  /// 
  /// First applies category filter, then search filter
  static List<Product> filterByCategoryAndSearch(
    List<Product> products,
    Category? selectedCategory,
    String searchQuery,
  ) {
    var filtered = filterByCategory(products, selectedCategory);
    
    if (searchQuery.isNotEmpty) {
      filtered = filterBySearchText(filtered, searchQuery);
    }
    
    return filtered;
  }

  /// Get filter summary for UI display
  /// 
  /// Returns formatted text describing current filter state
  static String getFilterSummary(
    int totalProducts,
    int filteredProducts,
    Category? selectedCategory,
    String searchQuery,
  ) {
    if (searchQuery.isNotEmpty && selectedCategory != null) {
      return 'Showing $filteredProducts of $totalProducts products in ${selectedCategory.displayName} matching "$searchQuery"';
    }
    
    if (searchQuery.isNotEmpty) {
      return 'Showing $filteredProducts of $totalProducts products matching "$searchQuery"';
    }
    
    if (selectedCategory != null) {
      return 'Showing $filteredProducts of $totalProducts products in ${selectedCategory.displayName}';
    }
    
    return 'Showing all $totalProducts products';
  }
}