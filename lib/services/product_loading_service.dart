import 'dart:async';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';

/// ProductLoadingService - Service for managing product data loading and state
///
/// This service handles all product loading logic that was previously
/// mixed with UI components. Provides a clean separation between
/// data loading concerns and UI presentation.
///
/// **Features:**
/// - Product loading state management
/// - Error handling and retry logic
/// - Centralized product data coordination
/// - Async/await pattern support
class ProductLoadingService {
  /// Load all products with proper error handling
  /// 
  /// Returns a result wrapper containing either products or error information
  static Future<ProductLoadResult> loadAllProducts(ProductBloc productBloc) async {
    try {
      final completer = Completer<ProductLoadResult>();
      
      // Set up the ProductBloc callback to handle results
      final bloc = initializeProductBloc((productOrProducts) {
        if (productOrProducts is List<Product>) {
          completer.complete(ProductLoadResult.success(productOrProducts));
        } else if (productOrProducts is String) {
          completer.complete(ProductLoadResult.error(productOrProducts));
        }
      });
      
      // Trigger the loading
      bloc.eventSink.add(LoadProducts());
      
      // Wait for result with timeout
      return await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => ProductLoadResult.error('Request timed out. Please try again.'),
      );
    } catch (e) {
      return ProductLoadResult.error('Failed to load products: ${e.toString()}');
    }
  }

  /// Initialize and configure ProductBloc with proper callback handling
  /// 
  /// Simplifies ProductBloc setup for consistent usage across components
  static ProductBloc initializeWithCallback(Function(dynamic) onResult) {
    return initializeProductBloc(onResult);
  }

  /// Check if products list is valid and not empty
  /// 
  /// Helper method for validation in UI components
  static bool hasValidProducts(List<Product>? products) {
    return products != null && products.isNotEmpty;
  }
}

/// ProductLoadResult - Result wrapper for product loading operations
/// 
/// Encapsulates success/error states with proper data handling
class ProductLoadResult {
  final List<Product>? products;
  final String? errorMessage;
  final bool isSuccess;

  const ProductLoadResult._({
    this.products,
    this.errorMessage,
    required this.isSuccess,
  });

  /// Create successful result with products
  factory ProductLoadResult.success(List<Product> products) {
    return ProductLoadResult._(
      products: products,
      isSuccess: true,
    );
  }

  /// Create error result with message
  factory ProductLoadResult.error(String message) {
    return ProductLoadResult._(
      errorMessage: message,
      isSuccess: false,
    );
  }

  /// Check if loading was successful
  bool get hasData => isSuccess && (products?.isNotEmpty ?? false);

  /// Check if there's an error
  bool get hasError => !isSuccess && errorMessage != null;

  /// Get error message or default
  String get error => errorMessage ?? 'Unknown error occurred';

  /// Get products or empty list
  List<Product> get data => products ?? [];
}