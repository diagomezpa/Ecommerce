import 'package:flutter_test/flutter_test.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import 'package:pragma_app_shell/helpers/product_classifier.dart';

void main() {
  group('ProductClassifier', () {
    // Test data setup
    late Product featuredProduct; // High rating (>=4.0)
    late Product promotionalProduct; // Low price (<50.0)
    late Product featuredPromotionalProduct; // Both high rating AND low price
    late Product regularProduct; // Neither featured nor promotional

    setUpAll(() {
      featuredProduct = Product(
        id: 1,
        title: 'Featured Product',
        price: 75.0, // High price
        description: 'High quality product',
        category: Category.ELECTRONICS,
        image: 'featured.jpg',
        rating: Rating(rate: 4.5, count: 100), // High rating
      );

      promotionalProduct = Product(
        id: 2,
        title: 'Promotional Product',
        price: 25.0, // Low price
        description: 'Affordable product',
        category: Category.WOMENS_CLOTHING,
        image: 'promo.jpg',
        rating: Rating(rate: 3.0, count: 50), // Low rating
      );

      featuredPromotionalProduct = Product(
        id: 3,
        title: 'Best Deal',
        price: 30.0, // Low price
        description: 'Great value for money',
        category: Category.ELECTRONICS,
        image: 'bestdeal.jpg',
        rating: Rating(rate: 4.8, count: 200), // High rating
      );

      regularProduct = Product(
        id: 4,
        title: 'Regular Product',
        price: 60.0, // High price
        description: 'Standard product',
        category: Category.JEWELERY,
        image: 'regular.jpg',
        rating: Rating(rate: 3.5, count: 30), // Low rating
      );
    });

    group('getFeaturedProducts', () {
      test('should return empty list for empty input', () {
        final result = ProductClassifier.getFeaturedProducts([]);
        expect(result, isEmpty);
      });

      test('should return only products with rating >= 4.0', () {
        final products = [featuredProduct, promotionalProduct, regularProduct];
        final result = ProductClassifier.getFeaturedProducts(products);
        
        expect(result, hasLength(1));
        expect(result.first.id, equals(featuredProduct.id));
      });

      test('should return multiple featured products', () {
        final products = [featuredProduct, featuredPromotionalProduct, regularProduct];
        final result = ProductClassifier.getFeaturedProducts(products);
        
        expect(result, hasLength(2));
        expect(result.map((p) => p.id), containsAll([1, 3]));
      });

      test('should return products with exactly 4.0 rating', () {
        final exactlyFeaturedProduct = Product(
          id: 5,
          title: 'Exactly Featured',
          price: 100.0,
          description: 'Test',
          category: Category.ELECTRONICS,
          image: 'test.jpg',
          rating: Rating(rate: 4.0, count: 10), // Exactly 4.0
        );
        
        final products = [exactlyFeaturedProduct, regularProduct];
        final result = ProductClassifier.getFeaturedProducts(products);
        
        expect(result, hasLength(1));
        expect(result.first.id, equals(5));
      });
    });

    group('getPromotionalProducts', () {
      test('should return empty list for empty input', () {
        final result = ProductClassifier.getPromotionalProducts([]);
        expect(result, isEmpty);
      });

      test('should return only products with price < 50.0', () {
        final products = [featuredProduct, promotionalProduct, regularProduct];
        final result = ProductClassifier.getPromotionalProducts(products);
        
        expect(result, hasLength(1));
        expect(result.first.id, equals(promotionalProduct.id));
      });

      test('should return multiple promotional products', () {
        final products = [promotionalProduct, featuredPromotionalProduct, featuredProduct];
        final result = ProductClassifier.getPromotionalProducts(products);
        
        expect(result, hasLength(2));
        expect(result.map((p) => p.id), containsAll([2, 3]));
      });

      test('should not return products with price exactly 50.0', () {
        final exactlyFiftyProduct = Product(
          id: 6,
          title: 'Fifty Dollar Product',
          price: 50.0,
          description: 'Test',
          category: Category.ELECTRONICS,
          image: 'test.jpg',
          rating: Rating(rate: 3.0, count: 10),
        );
        
        final products = [exactlyFiftyProduct, promotionalProduct];
        final result = ProductClassifier.getPromotionalProducts(products);
        
        expect(result, hasLength(1));
        expect(result.first.id, equals(promotionalProduct.id));
      });
    });

    group('classifyProducts', () {
      test('should return empty lists for empty input', () {
        final result = ProductClassifier.classifyProducts([]);
        
        expect(result.featured, isEmpty);
        expect(result.promotional, isEmpty);
      });

      test('should classify products correctly into both categories', () {
        final products = [
          featuredProduct,
          promotionalProduct,
          featuredPromotionalProduct,
          regularProduct,
        ];
        final result = ProductClassifier.classifyProducts(products);
        
        expect(result.featured, hasLength(2));
        expect(result.promotional, hasLength(2));
        expect(result.featured.map((p) => p.id), containsAll([1, 3]));
        expect(result.promotional.map((p) => p.id), containsAll([2, 3]));
      });

      test('should handle products that fit both categories', () {
        final products = [featuredPromotionalProduct];
        final result = ProductClassifier.classifyProducts(products);
        
        expect(result.featured, hasLength(1));
        expect(result.promotional, hasLength(1));
        expect(result.featured.first.id, equals(3));
        expect(result.promotional.first.id, equals(3));
      });
    });

    group('getClassificationSummary', () {
      test('should return correct summary for empty list', () {
        final result = ProductClassifier.getClassificationSummary([]);
        
        expect(result.totalProducts, equals(0));
        expect(result.featuredCount, equals(0));
        expect(result.promotionalCount, equals(0));
        expect(result.bothFeaturedAndPromotionalCount, equals(0));
        expect(result.featuredPercentage, equals(0));
        expect(result.promotionalPercentage, equals(0));
      });

      test('should calculate correct percentages', () {
        final products = [
          featuredProduct,
          promotionalProduct,
          featuredPromotionalProduct,
          regularProduct,
        ];
        final result = ProductClassifier.getClassificationSummary(products);
        
        expect(result.totalProducts, equals(4));
        expect(result.featuredCount, equals(2));
        expect(result.promotionalCount, equals(2));
        expect(result.bothFeaturedAndPromotionalCount, equals(1));
        expect(result.featuredPercentage, equals(50.0)); // 2/4 * 100 = 50%
        expect(result.promotionalPercentage, equals(50.0)); // 2/4 * 100 = 50%
      });

      test('should handle case with only featured products', () {
        final products = [featuredProduct];
        final result = ProductClassifier.getClassificationSummary(products);
        
        expect(result.totalProducts, equals(1));
        expect(result.featuredCount, equals(1));
        expect(result.promotionalCount, equals(0));
        expect(result.bothFeaturedAndPromotionalCount, equals(0));
        expect(result.featuredPercentage, equals(100.0));
        expect(result.promotionalPercentage, equals(0.0));
      });
    });

    group('getFeaturedPromotionalProducts', () {
      test('should return empty list for empty input', () {
        final result = ProductClassifier.getFeaturedPromotionalProducts([]);
        expect(result, isEmpty);
      });

      test('should return only products that are both featured AND promotional', () {
        final products = [
          featuredProduct,
          promotionalProduct,
          featuredPromotionalProduct,
          regularProduct,
        ];
        final result = ProductClassifier.getFeaturedPromotionalProducts(products);
        
        expect(result, hasLength(1));
        expect(result.first.id, equals(featuredPromotionalProduct.id));
      });

      test('should return multiple products that meet both criteria', () {
        final anotherFeaturedPromotional = Product(
          id: 7,
          title: 'Another Best Deal',
          price: 45.0, // Low price
          description: 'Another great value',
          category: Category.ELECTRONICS,
          image: 'anotherdeal.jpg',
          rating: Rating(rate: 4.2, count: 150), // High rating
        );
        
        final products = [featuredPromotionalProduct, anotherFeaturedPromotional];
        final result = ProductClassifier.getFeaturedPromotionalProducts(products);
        
        expect(result, hasLength(2));
        expect(result.map((p) => p.id), containsAll([3, 7]));
      });
    });
  });

  group('ProductClassificationResult', () {
    test('should have correct properties', () {
      final featured = [
        Product(
          id: 1,
          title: 'Featured',
          price: 100.0,
          description: 'Test',
          category: Category.ELECTRONICS,
          image: 'test.jpg',
          rating: Rating(rate: 4.5, count: 10),
        )
      ];
      final promotional = [
        Product(
          id: 2,
          title: 'Promotional',
          price: 25.0,
          description: 'Test',
          category: Category.ELECTRONICS,
          image: 'test.jpg',
          rating: Rating(rate: 3.0, count: 10),
        )
      ];

      final result = ProductClassificationResult(
        featured: featured,
        promotional: promotional,
      );

      expect(result.hasFeaturedProducts, isTrue);
      expect(result.hasPromotionalProducts, isTrue);
      expect(result.featured.length, equals(1));
      expect(result.promotional.length, equals(1));
    });

    test('should calculate total unique products correctly', () {
      final sharedProduct = Product(
        id: 1,
        title: 'Shared',
        price: 30.0,
        description: 'Test',
        category: Category.ELECTRONICS,
        image: 'test.jpg',
        rating: Rating(rate: 4.5, count: 10),
      );
      
      final result = ProductClassificationResult(
        featured: [sharedProduct],
        promotional: [sharedProduct],
      );

      expect(result.totalUniqueProducts, equals(1));
    });
  });

  group('ProductClassificationSummary', () {
    test('should format summary correctly', () {
      const summary = ProductClassificationSummary(
        totalProducts: 10,
        featuredCount: 3,
        promotionalCount: 4,
        bothFeaturedAndPromotionalCount: 1,
        featuredPercentage: 30.0,
        promotionalPercentage: 40.0,
      );

      final formatted = summary.formattedSummary;
      expect(formatted, contains('Total: 10'));
      expect(formatted, contains('Featured: 3 (30.0%)'));
      expect(formatted, contains('Promotional: 4 (40.0%)'));
      expect(formatted, contains('Both: 1'));
    });
  });
}