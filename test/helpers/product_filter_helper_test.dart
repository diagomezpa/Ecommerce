import 'package:flutter_test/flutter_test.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import 'package:pragma_app_shell/helpers/product_filter_helper.dart';

void main() {
  group('ProductFilterHelper', () {
    // Test data setup
    late List<Product> testProducts;

    setUpAll(() {
      testProducts = [
        Product(
          id: 1,
          title: 'iPhone 13',
          price: 999.99,
          description: 'Latest iPhone with amazing camera',
          category: Category.ELECTRONICS,
          image: 'iphone.jpg',
          rating: Rating(rate: 4.5, count: 100),
        ),
        Product(
          id: 2,
          title: 'Samsung Galaxy',
          price: 799.99,
          description: 'Android smartphone with great display',
          category: Category.ELECTRONICS,
          image: 'samsung.jpg',
          rating: Rating(rate: 4.2, count: 85),
        ),
        Product(
          id: 3,
          title: 'Cotton T-Shirt',
          price: 19.99,
          description: 'Comfortable cotton t-shirt for daily wear',
          category: Category.WOMENS_CLOTHING,
          image: 'tshirt.jpg',
          rating: Rating(rate: 4.0, count: 50),
        ),
        Product(
          id: 4,
          title: 'Diamond Ring',
          price: 2999.99,
          description: 'Beautiful diamond engagement ring',
          category: Category.JEWELERY,
          image: 'ring.jpg',
          rating: Rating(rate: 4.8, count: 25),
        ),
        Product(
          id: 5,
          title: 'Wireless Headphones',
          price: 199.99,
          description: 'High-quality wireless headphones with noise cancellation',
          category: Category.ELECTRONICS,
          image: 'headphones.jpg',
          rating: Rating(rate: 4.3, count: 120),
        ),
      ];
    });

    group('filterByCategory', () {
      test('should return all products when category is null', () {
        final result = ProductFilterHelper.filterByCategory(testProducts, null);
        
        expect(result, hasLength(testProducts.length));
        expect(result, equals(testProducts));
      });

      test('should return only electronics products', () {
        final result = ProductFilterHelper.filterByCategory(testProducts, Category.ELECTRONICS);
        
        expect(result, hasLength(3));
        expect(result.every((p) => p.category == Category.ELECTRONICS), isTrue);
        expect(result.map((p) => p.id), containsAll([1, 2, 5]));
      });

      test('should return only clothing products', () {
        final result = ProductFilterHelper.filterByCategory(testProducts, Category.WOMENS_CLOTHING);
        
        expect(result, hasLength(1));
        expect(result.first.category, equals(Category.WOMENS_CLOTHING));
        expect(result.first.id, equals(3));
      });

      test('should return only jewelery products', () {
        final result = ProductFilterHelper.filterByCategory(testProducts, Category.JEWELERY);
        
        expect(result, hasLength(1));
        expect(result.first.category, equals(Category.JEWELERY));
        expect(result.first.id, equals(4));
      });

      test('should return empty list for category with no products', () {
        final result = ProductFilterHelper.filterByCategory(testProducts, Category.MENS_CLOTHING);
        
        expect(result, isEmpty);
      });

      test('should return empty list for empty product list', () {
        final result = ProductFilterHelper.filterByCategory([], Category.ELECTRONICS);
        
        expect(result, isEmpty);
      });

      test('should return new list (not modify original)', () {
        final result = ProductFilterHelper.filterByCategory(testProducts, Category.ELECTRONICS);
        
        expect(identical(result, testProducts), isFalse);
        expect(testProducts, hasLength(5)); // Original list unchanged
      });
    });

    group('filterBySearchText', () {
      test('should return empty list for empty search query', () {
        final result = ProductFilterHelper.filterBySearchText(testProducts, '');
        
        expect(result, isEmpty);
      });

      test('should return all products for whitespace-only search query (behavior after trim)', () {
        final result = ProductFilterHelper.filterBySearchText(testProducts, '   ');
        
        // After trim(), empty string matches all products via contains('')
        expect(result, hasLength(5));
      });

      test('should find products by title (case-insensitive)', () {
        final result = ProductFilterHelper.filterBySearchText(testProducts, 'iphone');
        
        expect(result, hasLength(1));
        expect(result.first.id, equals(1));
      });

      test('should find products by title (case-sensitive input)', () {
        final result = ProductFilterHelper.filterBySearchText(testProducts, 'SAMSUNG');
        
        expect(result, hasLength(1));
        expect(result.first.id, equals(2));
      });

      test('should find products by description', () {
        final result = ProductFilterHelper.filterBySearchText(testProducts, 'camera');
        
        expect(result, hasLength(1));
        expect(result.first.id, equals(1));
      });

      test('should find products by partial title match', () {
        final result = ProductFilterHelper.filterBySearchText(testProducts, 'cotton');
        
        expect(result, hasLength(1));
        expect(result.first.id, equals(3));
      });

      test('should find products by partial description match', () {
        final result = ProductFilterHelper.filterBySearchText(testProducts, 'wireless');
        
        expect(result, hasLength(1));
        expect(result.first.id, equals(5));
      });

      test('should find multiple products matching search term', () {
        final result = ProductFilterHelper.filterBySearchText(testProducts, 'with');
        
        expect(result, hasLength(3)); // iPhone, Samsung, and Headphones all contain 'with'
        expect(result.map((p) => p.id), containsAll([1, 2, 5]));
      });

      test('should return empty list for non-matching search term', () {
        final result = ProductFilterHelper.filterBySearchText(testProducts, 'laptop');
        
        expect(result, isEmpty);
      });

      test('should handle special characters in search', () {
        final result = ProductFilterHelper.filterBySearchText(testProducts, 't-shirt');
        
        expect(result, hasLength(1));
        expect(result.first.id, equals(3));
      });

      test('should trim search query', () {
        final result = ProductFilterHelper.filterBySearchText(testProducts, '  iphone  ');
        
        expect(result, hasLength(1));
        expect(result.first.id, equals(1));
      });
    });

    group('filterByCategoryAndSearch', () {
      test('should filter by category only when search is empty', () {
        final result = ProductFilterHelper.filterByCategoryAndSearch(
          testProducts, 
          Category.ELECTRONICS, 
          '',
        );
        
        expect(result, hasLength(3));
        expect(result.every((p) => p.category == Category.ELECTRONICS), isTrue);
      });

      test('should filter by search only when category is null', () {
        final result = ProductFilterHelper.filterByCategoryAndSearch(
          testProducts, 
          null, 
          'ring',
        );
        
        expect(result, hasLength(1));
        expect(result.first.id, equals(4));
      });

      test('should filter by both category and search', () {
        final result = ProductFilterHelper.filterByCategoryAndSearch(
          testProducts, 
          Category.ELECTRONICS, 
          'samsung',
        );
        
        expect(result, hasLength(1));
        expect(result.first.id, equals(2));
        expect(result.first.category, equals(Category.ELECTRONICS));
      });

      test('should return empty list when both filters exclude all products', () {
        final result = ProductFilterHelper.filterByCategoryAndSearch(
          testProducts, 
          Category.WOMENS_CLOTHING, 
          'iphone',
        );
        
        expect(result, isEmpty);
      });

      test('should return all products when both filters are permissive', () {
        final result = ProductFilterHelper.filterByCategoryAndSearch(
          testProducts, 
          null, 
          '',
        );
        
        expect(result, hasLength(testProducts.length));
      });

      test('should handle whitespace in search term', () {
        final result = ProductFilterHelper.filterByCategoryAndSearch(
          testProducts, 
          Category.ELECTRONICS, 
          '   wireless   ',
        );
        
        expect(result, hasLength(1));
        expect(result.first.id, equals(5));
      });

      test('should apply category filter first, then search filter', () {
        // First filters to electronics (3 products), then searches for 'phone' (2 products)
        final result = ProductFilterHelper.filterByCategoryAndSearch(
          testProducts, 
          Category.ELECTRONICS, 
          'phone',
        );
        
        expect(result, hasLength(3)); // iPhone, Samsung (Galaxy), and Headphones all contain 'phone'
        expect(result.every((p) => p.category == Category.ELECTRONICS), isTrue);
      });
    });

    group('getFilterSummary', () {
      test('should return summary for no filters', () {
        final result = ProductFilterHelper.getFilterSummary(
          5, 5, null, '',
        );
        
        expect(result, equals('Showing all 5 products'));
      });

      test('should return summary for search filter only', () {
        final result = ProductFilterHelper.getFilterSummary(
          5, 2, null, 'phone',
        );
        
        expect(result, equals('Showing 2 of 5 products matching "phone"'));
      });

      test('should return summary for category filter only', () {
        final result = ProductFilterHelper.getFilterSummary(
          5, 3, Category.ELECTRONICS, '',
        );
        
        expect(result, equals('Showing 3 of 5 products in Electronics'));
      });

      test('should return summary for both filters', () {
        final result = ProductFilterHelper.getFilterSummary(
          5, 1, Category.ELECTRONICS, 'samsung',
        );
        
        expect(result, equals('Showing 1 of 5 products in Electronics matching "samsung"'));
      });

      test('should handle zero filtered products with search', () {
        final result = ProductFilterHelper.getFilterSummary(
          5, 0, null, 'laptop',
        );
        
        expect(result, equals('Showing 0 of 5 products matching "laptop"'));
      });

      test('should handle zero filtered products with category', () {
        final result = ProductFilterHelper.getFilterSummary(
          5, 0, Category.MENS_CLOTHING, '',
        );
        
        expect(result, equals('Showing 0 of 5 products in Men\'s Clothing'));
      });

      test('should handle zero filtered products with both filters', () {
        final result = ProductFilterHelper.getFilterSummary(
          5, 0, Category.WOMENS_CLOTHING, 'iphone',
        );
        
        expect(result, equals('Showing 0 of 5 products in Women\'s Clothing matching "iphone"'));
      });
    });
  });
}