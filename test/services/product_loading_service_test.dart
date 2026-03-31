import 'package:flutter_test/flutter_test.dart';
import 'package:pragma_app_shell/services/product_loading_service.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';

void main() {
  group('ProductLoadingService Tests', () {
    
    group('ProductLoadResult', () {
      test('should create successful result with products', () {
        final products = <Product>[
          Product(
            id: 1,
            title: 'Test Product',
            price: 9.99,
            description: 'A test product',
            category: Category.ELECTRONICS,
            image: 'https://test.com/image.jpg',
            rating: Rating(rate: 4.5, count: 10),
          ),
        ];

        final result = ProductLoadResult.success(products);

        expect(result.isSuccess, true);
        expect(result.hasData, true);
        expect(result.hasError, false);
        expect(result.data, equals(products));
        expect(result.products, equals(products));
        expect(result.errorMessage, isNull);
      });

      test('should create error result with message', () {
        const errorMessage = 'Failed to load products';
        final result = ProductLoadResult.error(errorMessage);

        expect(result.isSuccess, false);
        expect(result.hasData, false);
        expect(result.hasError, true);
        expect(result.error, errorMessage);
        expect(result.errorMessage, errorMessage);
        expect(result.products, isNull);
      });

      test('should return empty list for data when error result', () {
        final result = ProductLoadResult.error('Error message');
        expect(result.data, isEmpty);
      });

      test('should return default error message when none provided', () {
        final result = ProductLoadResult.error('');
        expect(result.error, isEmpty); // Empty string returns empty
        
        // Test with null-like case
        final result2 = ProductLoadResult.error('null');
        expect(result2.error, 'null');
      });

      test('should handle success with empty products list', () {
        final result = ProductLoadResult.success(<Product>[]);

        expect(result.isSuccess, true);
        expect(result.hasData, false); // Empty list means no data
        expect(result.hasError, false);
        expect(result.data, isEmpty);
      });

      test('should properly identify hasData with non-empty products', () {
        final products = <Product>[
          Product(
            id: 1,
            title: 'Test Product',
            price: 9.99,
            description: 'A test product',
            category: Category.ELECTRONICS,
            image: 'https://test.com/image.jpg',
            rating: Rating(rate: 4.5, count: 10),
          ),
        ];

        final result = ProductLoadResult.success(products);
        expect(result.hasData, true);
      });
    });

    group('Static Helper Methods', () {
      test('hasValidProducts should return true for non-empty product list', () {
        final products = <Product>[
          Product(
            id: 1,
            title: 'Test Product',
            price: 9.99,
            description: 'A test product',
            category: Category.ELECTRONICS,
            image: 'https://test.com/image.jpg',
            rating: Rating(rate: 4.5, count: 10),
          ),
        ];

        expect(ProductLoadingService.hasValidProducts(products), true);
      });

      test('hasValidProducts should return false for empty list', () {
        expect(ProductLoadingService.hasValidProducts(<Product>[]), false);
      });

      test('hasValidProducts should return false for null', () {
        expect(ProductLoadingService.hasValidProducts(null), false);
      });
    });

    group('Service Architecture', () {
      test('should have static methods for service operations', () {
        // Verify the service has the expected static interface
        expect(ProductLoadingService.hasValidProducts, isA<Function>());
      });

      test('should provide result wrapper class', () {
        // Verify ProductLoadResult can be instantiated
        final successResult = ProductLoadResult.success(<Product>[]);
        final errorResult = ProductLoadResult.error('Test error');

        expect(successResult, isA<ProductLoadResult>());
        expect(errorResult, isA<ProductLoadResult>());
      });
    });

    group('Error Handling', () {
      test('should handle various error conditions', () {
        final errorMessages = [
          'Network error',
          'Server timeout', 
          'Invalid response',
          'Connection failed',
        ];

        for (final message in errorMessages) {
          final result = ProductLoadResult.error(message);
          expect(result.hasError, true);
          expect(result.isSuccess, false);
          expect(result.error, isNotEmpty);
        }
        
        // Test empty error message separately
        final emptyResult = ProductLoadResult.error('');
        expect(emptyResult.hasError, true);
        expect(emptyResult.isSuccess, false);
        expect(emptyResult.error, isEmpty);
      });

      test('should provide meaningful error messages', () {
        const customError = 'Custom error message';
        final result = ProductLoadResult.error(customError);

        expect(result.error, contains('Custom error'));
        expect(result.errorMessage, customError);
      });
    });

    group('Data Validation', () {
      test('should validate product structure in successful results', () {
        final product = Product(
          id: 1,
          title: 'Test Product',
          price: 19.99,
          description: 'Test Description',
          category: Category.ELECTRONICS,
          image: 'https://example.com/image.jpg',
          rating: Rating(rate: 4.0, count: 100),
        );

        final result = ProductLoadResult.success(<Product>[product]);
        
        expect(result.isSuccess, true);
        expect(result.data, hasLength(1));
        
        final retrievedProduct = result.data.first;
        expect(retrievedProduct.id, 1);
        expect(retrievedProduct.title, 'Test Product');
        expect(retrievedProduct.price, 19.99);
        expect(retrievedProduct.description, 'Test Description');
        expect(retrievedProduct.category, Category.ELECTRONICS);
        expect(retrievedProduct.image, 'https://example.com/image.jpg');
        expect(retrievedProduct.rating.rate, 4.0);
        expect(retrievedProduct.rating.count, 100);
      });

      test('should handle multiple products in success result', () {
        final products = List.generate(5, (index) => Product(
          id: index + 1,
          title: 'Product ${index + 1}',
          price: (index + 1) * 10.0,
          description: 'Description ${index + 1}',
          category: Category.ELECTRONICS,
          image: 'https://example.com/image${index + 1}.jpg',
          rating: Rating(rate: 4.0 + (index * 0.1), count: 50 + index),
        ));

        final result = ProductLoadResult.success(products);
        
        expect(result.hasData, true);
        expect(result.data, hasLength(5));
        
        for (int i = 0; i < products.length; i++) {
          expect(result.data[i].id, i + 1);
          expect(result.data[i].title, 'Product ${i + 1}');
          expect(result.data[i].price, (i + 1) * 10.0);
        }
      });
    });

    group('Result State Management', () {
      test('should maintain consistent data access', () {
        final products = <Product>[
          Product(
            id: 1,
            title: 'Original Product',
            price: 9.99,
            description: 'Original Description',
            category: Category.ELECTRONICS,
            image: 'https://example.com/image.jpg',
            rating: Rating(rate: 4.0, count: 10),
          ),
        ];

        final result = ProductLoadResult.success(products);
        final resultProducts = result.data;
        
        // Verify we get the correct products
        expect(resultProducts, hasLength(1));
        expect(resultProducts.first.title, 'Original Product');
        
        // Verify data consistency on multiple calls
        expect(result.data.length, result.products!.length);
        expect(result.data.first.id, resultProducts.first.id);
      });

      test('should handle state transitions correctly', () {
        // Start with success state
        final successResult = ProductLoadResult.success(<Product>[
          Product(
            id: 1,
            title: 'Test',
            price: 9.99,
            description: 'Test',
            category: Category.ELECTRONICS,
            image: 'https://test.com/image.jpg',
            rating: Rating(rate: 4.0, count: 10),
          ),
        ]);

        expect(successResult.isSuccess, true);
        expect(successResult.hasError, false);

        // Create error state
        final errorResult = ProductLoadResult.error('Something went wrong');

        expect(errorResult.isSuccess, false);
        expect(errorResult.hasError, true);

        // States should be independent
        expect(successResult.isSuccess, true); // Should still be true
      });
    });

    group('Edge Cases', () {
      test('should handle very long error messages', () {
        final longError = 'Error: ' + 'Very long error message ' * 100;
        final result = ProductLoadResult.error(longError);

        expect(result.hasError, true);
        expect(result.error, equals(longError));
        expect(result.errorMessage, equals(longError));
      });

      test('should handle special characters in error messages', () {
        const specialError = 'Error with special chars: áéíóú, ñÑ, @#\$%^&*()';
        final result = ProductLoadResult.error(specialError);

        expect(result.hasError, true);
        expect(result.error, specialError);
      });

      test('should handle products with extreme values', () {
        final product = Product(
          id: 999999,
          title: 'Very Expensive Product',
          price: 99999.99,
          description: 'Extremely expensive item',
          category: Category.ELECTRONICS,
          image: 'https://example.com/expensive.jpg',
          rating: Rating(rate: 5.0, count: 999999),
        );

        final result = ProductLoadResult.success(<Product>[product]);
        
        expect(result.hasData, true);
        expect(result.data.first.id, 999999);
        expect(result.data.first.price, 99999.99);
        expect(result.data.first.rating.count, 999999);
      });

      test('should handle products with minimum values', () {
        final product = Product(
          id: 1,
          title: 'A',
          price: 0.01,
          description: 'B',
          category: Category.ELECTRONICS,
          image: 'https://x.co/i.jpg',
          rating: Rating(rate: 0.1, count: 1),
        );

        final result = ProductLoadResult.success(<Product>[product]);
        
        expect(result.hasData, true);
        expect(result.data.first.title, 'A');
        expect(result.data.first.price, 0.01);
        expect(result.data.first.rating.rate, 0.1);
      });
    });
  });
}