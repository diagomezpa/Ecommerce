import 'package:flutter_test/flutter_test.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import 'package:pragma_app_shell/helpers/cart_calculation_helper.dart';

void main() {
  group('CartCalculationHelper', () {
    // Test data setup
    late Product testProduct1;
    late Product testProduct2;
    late Products cartProduct1;
    late Products cartProduct2;
    late Cart emptyCart;
    late Cart cartWithProducts;

    setUpAll(() {
      // Create test products
      testProduct1 = Product(
        id: 1,
        title: 'Test Product 1',
        price: 10.0,
        description: 'Test description',
        category: Category.ELECTRONICS,
        image: 'test.jpg',
        rating: Rating(rate: 4.5, count: 100),
      );

      testProduct2 = Product(
        id: 2,
        title: 'Test Product 2',
        price: 25.0,
        description: 'Test description 2',
        category: Category.ELECTRONICS,
        image: 'test2.jpg',
        rating: Rating(rate: 3.5, count: 50),
      );

      // Create cart products
      cartProduct1 = Products(
        productId: 1,
        productDetails: testProduct1,
        quantity: 2,
      );

      cartProduct2 = Products(
        productId: 2,
        productDetails: testProduct2,
        quantity: 3,
      );

      // Create empty cart
      emptyCart = Cart(id: 1, userId: 1, date: DateTime.now(), products: []);

      // Create cart with products
      cartWithProducts = Cart(id: 2, userId: 1, date: DateTime.now(), products: [cartProduct1, cartProduct2]);
    });

    group('calculateTotalItems', () {
      test('should return 0 for cart with null products', () {
        final cart = Cart(id: 1, userId: 1, date: DateTime.now(), products: null);
        final result = CartCalculationHelper.calculateTotalItems(cart);
        expect(result, equals(0));
      });

      test('should return 0 for empty cart', () {
        final result = CartCalculationHelper.calculateTotalItems(emptyCart);
        expect(result, equals(0));
      });

      test('should calculate correct total items', () {
        final result = CartCalculationHelper.calculateTotalItems(cartWithProducts);
        expect(result, equals(5)); // 2 + 3 = 5 items
      });

      test('should handle single item cart', () {
        final cart = Cart(id: 3, userId: 1, date: DateTime.now(), products: [cartProduct1]);
        final result = CartCalculationHelper.calculateTotalItems(cart);
        expect(result, equals(2));
      });
    });

    group('calculateCartTotal', () {
      test('should return 0.0 for cart with null products', () {
        final cart = Cart(id: 1, userId: 1, date: DateTime.now(), products: null);
        final result = CartCalculationHelper.calculateCartTotal(cart);
        expect(result, equals(0.0));
      });

      test('should return 0.0 for empty cart', () {
        final result = CartCalculationHelper.calculateCartTotal(emptyCart);
        expect(result, equals(0.0));
      });

      test('should calculate correct cart total', () {
        final result = CartCalculationHelper.calculateCartTotal(cartWithProducts);
        expect(result, equals(95.0)); // (10.0 * 2) + (25.0 * 3) = 20 + 75 = 95
      });

      test('should handle product with null price', () {
        final productWithNullPrice = Product(
          id: 3,
          title: 'Test Product',
          price: 0.0, // null price defaults to 0.0
          description: 'Test',
          category: Category.ELECTRONICS,
          image: 'test.jpg',
          rating: Rating(rate: 4.0, count: 10),
        );
        final cartProductWithNullPrice = Products(
          productId: 3,
          productDetails: productWithNullPrice,
          quantity: 2,
        );
        final cart = Cart(id: 4, userId: 1, date: DateTime.now(), products: [cartProductWithNullPrice]);
        
        final result = CartCalculationHelper.calculateCartTotal(cart);
        expect(result, equals(0.0));
      });
    });

    group('calculateItemSubtotal', () {
      test('should calculate correct subtotal for cart product', () {
        final result = CartCalculationHelper.calculateItemSubtotal(cartProduct1);
        expect(result, equals(20.0)); // 10.0 * 2 = 20.0
      });

      test('should calculate correct subtotal for different quantities', () {
        final result = CartCalculationHelper.calculateItemSubtotal(cartProduct2);
        expect(result, equals(75.0)); // 25.0 * 3 = 75.0
      });

      test('should handle null price in product details', () {
        final cartProductWithNullPrice = Products(
          productId: 0,
          productDetails: null,
          quantity: 2,
        );
        
        final result = CartCalculationHelper.calculateItemSubtotal(cartProductWithNullPrice);
        expect(result, equals(0.0));
      });
    });

    group('hasItems', () {
      test('should return false for cart with null products', () {
        final cart = Cart(id: 1, userId: 1, date: DateTime.now(), products: null);
        final result = CartCalculationHelper.hasItems(cart);
        expect(result, equals(false));
      });

      test('should return false for empty cart', () {
        final result = CartCalculationHelper.hasItems(emptyCart);
        expect(result, equals(false));
      });

      test('should return true for cart with products', () {
        final result = CartCalculationHelper.hasItems(cartWithProducts);
        expect(result, equals(true));
      });
    });

    group('getCartSummary', () {
      test('should return correct summary for empty cart', () {
        final result = CartCalculationHelper.getCartSummary(emptyCart);
        
        expect(result.totalItems, equals(0));
        expect(result.totalPrice, equals(0.0));
        expect(result.hasItems, equals(false));
        expect(result.cartId, equals('1'));
      });

      test('should return correct summary for cart with products', () {
        final result = CartCalculationHelper.getCartSummary(cartWithProducts);
        
        expect(result.totalItems, equals(5));
        expect(result.totalPrice, equals(95.0));
        expect(result.hasItems, equals(true));
        expect(result.cartId, equals('2'));
      });

      test('should handle cart with null id', () {
        final cartWithNullId = Cart(id: null, userId: 1, date: DateTime.now(), products: [cartProduct1]);
        final result = CartCalculationHelper.getCartSummary(cartWithNullId);
        
        expect(result.cartId, equals('N/A'));
      });
    });
  });

  group('CartSummary', () {
    test('should format total price correctly', () {
      const summary = CartSummary(
        totalItems: 3,
        totalPrice: 123.456,
        hasItems: true,
        cartId: '1',
      );
      
      expect(summary.formattedTotal, equals('\$123.46'));
    });

    test('should format items count for single item', () {
      const summary = CartSummary(
        totalItems: 1,
        totalPrice: 10.0,
        hasItems: true,
        cartId: '1',
      );
      
      expect(summary.formattedItemsCount, equals('1 item'));
    });

    test('should format items count for multiple items', () {
      const summary = CartSummary(
        totalItems: 5,
        totalPrice: 50.0,
        hasItems: true,
        cartId: '1',
      );
      
      expect(summary.formattedItemsCount, equals('5 items'));
    });

    test('should format items count for zero items', () {
      const summary = CartSummary(
        totalItems: 0,
        totalPrice: 0.0,
        hasItems: false,
        cartId: '1',
      );
      
      expect(summary.formattedItemsCount, equals('0 items'));
    });
  });
}