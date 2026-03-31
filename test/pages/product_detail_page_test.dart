import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pragma_app_shell/pages/product_detail_page.dart';
import 'package:pragma_design_system/pragma_design_system.dart' as design;
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';

void main() {
  group('ProductDetailPage Widget Tests', () {
    
    late Product testProduct;

    setUp(() {
      testProduct = Product(
        id: 1,
        title: 'Test Product',
        description: 'Test product description with details about the item.',
        price: 29.99,
        image: 'https://example.com/test-image.jpg',
        category: Category.ELECTRONICS,
        rating: Rating(rate: 4.5, count: 120),
      );
    });

    testWidgets('should render correctly with main UI structure', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();

      // Assert - Verify basic page structure
      expect(find.byType(ProductDetailPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Product Details'), findsOneWidget);
    });

    testWidgets('should show loading state initially', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();

      // Assert - Should show loading indicator or basic structure
      expect(find.byType(ProductDetailPage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have shopping cart icon in app bar', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();

      // Assert - Should have cart icon in app bar
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('should handle different product IDs', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: 999),
        ),
      );
      await tester.pump();

      // Assert - Should handle different IDs
      expect(find.byType(ProductDetailPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should maintain widget key functionality', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(
            key: const Key('product_detail_page_key'),
            productId: testProduct.id,
          ),
        ),
      );
      await tester.pump();

      // Assert - Should find widget by key
      expect(find.byKey(const Key('product_detail_page_key')), findsOneWidget);
    });

    testWidgets('should be stateful widget', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();

      // Assert - Should be stateful
      expect(find.byType(ProductDetailPage), findsOneWidget);
      final widget = tester.widget<ProductDetailPage>(find.byType(ProductDetailPage));
      expect(widget, isA<StatefulWidget>());
    });

    testWidgets('should handle widget rebuilds correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();

      // Act - Force rebuild
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Should still be functional after rebuild
      expect(find.byType(ProductDetailPage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should maintain consistent widget hierarchy', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();

      // Assert - Should have consistent structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(ProductDetailPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle navigation context properly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: Text('Previous Page')),
          onGenerateRoute: (settings) {
            if (settings.name == '/product_detail') {
              return MaterialPageRoute(
                builder: (context) => ProductDetailPage(productId: testProduct.id),
              );
            }
            return null;
          },
        ),
      );
      
      // Navigate to product detail
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pushNamed('/product_detail');
      await tester.pump();

      // Act - Try to go back
      navigator.pop();
      await tester.pump();

      // Assert - Should navigate back
      expect(find.text('Previous Page'), findsOneWidget);
    });

    testWidgets('should initialize with valid constructor parameters', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();

      // Assert - Should initialize properly with productId
      final widget = tester.widget<ProductDetailPage>(find.byType(ProductDetailPage));
      expect(widget.productId, equals(testProduct.id));
    });
  });
}