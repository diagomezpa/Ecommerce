import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';

/// CartCalculationHelper - Business logic for cart calculations
///
/// This helper centralizes all cart-related calculations that were
/// previously scattered across UI components. Extracted to maintain
/// separation of concerns and ensure data consistency.
///
/// **Features:**
/// - Cart total calculations
/// - Item count calculations  
/// - Subtotal calculations
/// - Centralized and reusable logic
/// - Easy to test and maintain
class CartCalculationHelper {
  /// Calculate total number of items in cart
  /// 
  /// Sums up all product quantities in the cart
  static int calculateTotalItems(Cart cart) {
    if (cart.products == null || cart.products!.isEmpty) {
      return 0;
    }
    
    return cart.products!.fold<int>(
      0, 
      (sum, product) => sum + product.quantity,
    );
  }

  /// Calculate total price of all items in cart
  /// 
  /// Multiplies price by quantity for each product and sums everything
  static double calculateCartTotal(Cart cart) {
    if (cart.products == null || cart.products!.isEmpty) {
      return 0.0;
    }
    
    return cart.products!.fold<double>(
      0.0, 
      (sum, product) {
        final price = product.productDetails?.price ?? 0.0;
        return sum + (price * product.quantity);
      },
    );
  }

  /// Calculate subtotal for a specific cart item
  /// 
  /// Price × Quantity for individual product
  static double calculateItemSubtotal(Products cartProduct) {
    final price = cartProduct.productDetails?.price ?? 0.0;
    return price * cartProduct.quantity;
  }

  /// Check if cart has any items
  /// 
  /// Utility method to check for empty cart state
  static bool hasItems(Cart cart) {
    return cart.products != null && cart.products!.isNotEmpty;
  }

  /// Get formatted cart summary for display
  /// 
  /// Returns a summary object with calculated values ready for UI
  static CartSummary getCartSummary(Cart cart) {
    return CartSummary(
      totalItems: calculateTotalItems(cart),
      totalPrice: calculateCartTotal(cart),
      hasItems: hasItems(cart),
      cartId: cart.id?.toString() ?? 'N/A',
    );
  }
}

/// CartSummary - Data class for cart summary information
/// 
/// Encapsulates calculated cart data in a structured format
class CartSummary {
  final int totalItems;
  final double totalPrice;
  final bool hasItems;
  final String cartId;

  const CartSummary({
    required this.totalItems,
    required this.totalPrice,
    required this.hasItems,
    required this.cartId,
  });

  /// Get formatted total price string
  String get formattedTotal => '\$${totalPrice.toStringAsFixed(2)}';

  /// Get formatted items count string
  String get formattedItemsCount => '$totalItems item${totalItems != 1 ? 's' : ''}';
}