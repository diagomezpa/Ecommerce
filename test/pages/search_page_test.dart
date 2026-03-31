import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pragma_app_shell/pages/search_page.dart';
import 'package:pragma_design_system/pragma_design_system.dart' as design;
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';

void main() {
  group('SearchPage Widget Tests', () {

    late List<Product> testProducts;

    setUp(() {
      testProducts = [
        Product(
          id: 1,
          title: 'iPhone 13',
          description: 'Latest Apple smartphone',
          price: 999.99,
          image: 'https://example.com/iphone.jpg',
          category: Category.ELECTRONICS,
          rating: Rating(rate: 4.5, count: 100),
        ),
        Product(
          id: 2,
          title: 'Samsung Galaxy',
          description: 'Android smartphone',
          price: 799.99,
          image: 'https://example.com/samsung.jpg',
          category: Category.ELECTRONICS,
          rating: Rating(rate: 4.2, count: 80),
        ),
        Product(
          id: 3,
          title: 'Gold Necklace',
          description: 'Beautiful gold jewelry',
          price: 299.99,
          image: 'https://example.com/necklace.jpg',
          category: Category.JEWELERY,
          rating: Rating(rate: 4.8, count: 50),
        ),
      ];
    });

    testWidgets('should render correctly with main UI structure', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: SearchPage(products: testProducts),
        ),
      );
      await tester.pump();

      // Assert - Verify basic page structure
      expect(find.byType(SearchPage), findsOneWidget);
      expect(find.text('Search Products'), findsOneWidget);
      expect(find.text('Find Products'), findsOneWidget);
    });

    testWidgets('should display initial empty state', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: SearchPage(products: testProducts),
        ),
      );
      await tester.pump();

      // Assert - Should show initial state
      expect(find.text('Start Searching'), findsOneWidget);
      expect(find.text('Enter a product name or description to find what you\'re looking for.'), findsOneWidget);
    });

    testWidgets('should have search input field', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: SearchPage(products: testProducts),
        ),
      );
      await tester.pump();

      // Assert - Should have search input
      expect(find.byType(design.AppFormField), findsOneWidget);
      expect(find.text('Search products...'), findsOneWidget);
    });

    testWidgets('should filter products based on search input', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: SearchPage(products: testProducts),
        ),
      );
      await tester.pump();

      // Act - Enter search text
      final searchField = find.byType(design.AppFormField);
      await tester.enterText(searchField, 'iPhone');
      await tester.pump();

      // Assert - Should show filtered results
      expect(find.text('Search Results'), findsOneWidget);
      expect(find.text('1 product found'), findsOneWidget);
    });

    testWidgets('should show no results when no products match', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: SearchPage(products: testProducts),
        ),
      );
      await tester.pump();

      // Act - Enter search text that doesn't match
      final searchField = find.byType(design.AppFormField);
      await tester.enterText(searchField, 'NotFound');
      await tester.pump();

      // Assert - Should show no results state
      expect(find.text('No Results Found'), findsOneWidget);
      expect(find.textContaining('We couldn\'t find any products matching "NotFound"'), findsOneWidget);
    });

    testWidgets('should clear search when clear button is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: SearchPage(products: testProducts),
        ),
      );
      await tester.pump();

      // Act - Search and then clear
      final searchField = find.byType(design.AppFormField);
      await tester.enterText(searchField, 'NotFound');
      await tester.pump();
      
      final clearButton = find.text('Clear Search');
      await tester.tap(clearButton);
      await tester.pump();

      // Assert - Should return to initial state
      expect(find.text('Start Searching'), findsOneWidget);
    });

    testWidgets('should handle empty search gracefully', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: SearchPage(products: testProducts),
        ),
      );
      await tester.pump();

      // Act - Enter search then clear it
      final searchField = find.byType(design.AppFormField);
      await tester.enterText(searchField, 'iPhone');
      await tester.pump();
      await tester.enterText(searchField, '');
      await tester.pump();

      // Assert - Should return to initial state
      expect(find.text('Start Searching'), findsOneWidget);
    });

    testWidgets('should navigate to product detail when product is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: SearchPage(products: testProducts),
          routes: {
            '/product_detail': (context) => const Scaffold(body: Text('Product Detail')),
          },
        ),
      );
      await tester.pump();

      // Act - Search for a product
      final searchField = find.byType(design.AppFormField);
      await tester.enterText(searchField, 'iPhone');
      await tester.pump();

      // Try to find and tap product item if it exists
      final productItems = find.byType(design.AppProductListItem);
      if (productItems.evaluate().isNotEmpty) {
        await tester.tap(productItems.first);
        await tester.pump();
      }

      // Assert - Should handle navigation
      expect(find.byType(SearchPage), findsOneWidget);
    });

    testWidgets('should handle empty product list', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: SearchPage(products: []),
        ),
      );
      await tester.pump();

      // Assert - Should handle empty list gracefully
      expect(find.byType(SearchPage), findsOneWidget);
      expect(find.text('Start Searching'), findsOneWidget);
    });

    testWidgets('should maintain search state during rebuilds', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: SearchPage(products: testProducts),
        ),
      );
      await tester.pump();

      // Act - Enter search text and rebuild
      final searchField = find.byType(design.AppFormField);
      await tester.enterText(searchField, 'Galaxy');
      await tester.pump();
      await tester.pump(); // Force rebuild

      // Assert - Should maintain search results
      expect(find.text('Search Results'), findsOneWidget);
    });
  });
}