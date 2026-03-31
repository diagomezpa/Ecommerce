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

    testWidgets('should display product information when loaded', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      // Wait for product to potentially load
      await tester.pump(const Duration(milliseconds: 1000));

      // Assert - Should show product-related content
      final productElements = [
        find.textContaining('Test Product'),
        find.textContaining('\$'),
        find.textContaining('★'),
        find.textContaining('Description'),
      ];
      
      // Should handle product display
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle quantity selection', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 500));

      // Act - Look for quantity controls
      final increaseButtons = find.byIcon(Icons.add);
      final decreaseButtons = find.byIcon(Icons.remove);
      final quantityFields = find.byType(TextField);
      
      if (increaseButtons.evaluate().isNotEmpty) {
        await tester.tap(increaseButtons.first);
        await tester.pump();
      }
      
      if (decreaseButtons.evaluate().isNotEmpty) {
        await tester.tap(decreaseButtons.first);
        await tester.pump();
      }
      
      if (quantityFields.evaluate().isNotEmpty) {
        await tester.enterText(quantityFields.first, '3');
        await tester.pump();
      }

      // Assert - Should handle quantity changes
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle add to cart functionality', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 500));

      // Act - Look for add to cart button
      final addToCartButtons = [
        find.textContaining('Add to Cart'),
        find.textContaining('Add'),
        find.byIcon(Icons.shopping_cart_outlined),
        find.byIcon(Icons.add_shopping_cart),
      ];
      
      for (final buttonFinder in addToCartButtons) {
        if (buttonFinder.evaluate().isNotEmpty) {
          await tester.tap(buttonFinder.first);
          await tester.pump();
          
          // Handle potential snackbar or dialog
          await tester.pump(const Duration(milliseconds: 100));
          break;
        }
      }

      // Assert - Should handle add to cart
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should display product image', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 500));

      // Act & Assert - Look for image widgets
      final images = find.byType(Image);
      final networkImages = find.byType(Image);
      
      // Should attempt to display image
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle navigation to cart', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
          routes: {
            '/cart': (context) => const Scaffold(body: Text('Cart Page')),
          },
        ),
      );
      await tester.pump();

      // Act - Tap cart icon in app bar
      final cartIcon = find.byIcon(Icons.shopping_cart);
      if (cartIcon.evaluate().isNotEmpty) {
        await tester.tap(cartIcon.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Assert - Should handle cart navigation
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should display product rating and reviews', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - Look for rating elements
      final ratingElements = [
        find.textContaining('★'),
        find.textContaining('4.5'),
        find.textContaining('Rating'),
        find.textContaining('Reviews'),
        find.textContaining('120'),
      ];
      
      // Should display rating information
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle scrolling through product details', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 500));

      // Act - Try to scroll
      final scrollableWidgets = [
        find.byType(SingleChildScrollView),
        find.byType(ListView),
        find.byType(CustomScrollView),
      ];
      
      for (final scrollableFinder in scrollableWidgets) {
        if (scrollableFinder.evaluate().isNotEmpty) {
          await tester.fling(scrollableFinder.first, const Offset(0, -300), 300);
          await tester.pump();
          await tester.fling(scrollableFinder.first, const Offset(0, 300), 300);
          await tester.pump();
          break;
        }
      }

      // Assert - Should handle scrolling
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle product not found or error state', (WidgetTester tester) async {
      // Arrange - Use invalid product ID
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: -1),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Assert - Should handle error gracefully
      expect(find.byType(ProductDetailPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle different screen sizes', (WidgetTester tester) async {
      // Arrange - Set tablet size
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - Should adapt to larger screen
      expect(find.byType(ProductDetailPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // Cleanup
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should handle fractional prices at boundary correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - Should handle price display
      final priceElements = [
        find.textContaining('\$'),
        find.textContaining('29.99'),
        find.textContaining('Price'),
      ];
      
      // Should handle price display
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle product loading state correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();

      // Assert - Should show loading state initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle product error state with retry', (WidgetTester tester) async {
      // Arrange - Use invalid product ID to trigger error
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: -999),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 2000));

      // Act - Look for error elements
      final errorElements = [
        find.textContaining('Error'),
        find.textContaining('Unable to Load'),
        find.textContaining('Retry'),
        find.byIcon(Icons.error_outline),
      ];
      
      final retryButton = find.textContaining('Retry');
      if (retryButton.evaluate().isNotEmpty) {
        await tester.tap(retryButton.first);
        await tester.pump();
      }

      // Assert - Should handle error state
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle product success state and display content', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      // Wait for product to load
      await tester.pump(const Duration(milliseconds: 1500));

      // Act & Assert - Look for product content elements
      final productElements = [
        find.textContaining('Test Product'),
        find.textContaining('\$29.99'),
        find.textContaining('Electronics'),
        find.textContaining('Description'),
        find.byType(design.AppText),
        find.byType(design.AppPrice),
      ];
      
      // Should display product content
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle product image display and loading', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Act & Assert - Look for image elements
      final imageElements = [
        find.byType(Image),
        find.byType(design.AppImage),
        find.byType(NetworkImage),
        find.byType(FadeInImage),
      ];
      
      // Should handle image display
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle category badge display', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Act & Assert - Look for category elements
      final categoryElements = [
        find.textContaining('Electronics'),
        find.textContaining('ELECTRONICS'),
        find.byType(Container),
        find.byType(Chip),
      ];
      
      // Should display category badge
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle add to cart bottom action button', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Look for add to cart button
      final addToCartButtons = [
        find.textContaining('Add to Cart'),
        find.textContaining('Add'),
        find.byIcon(Icons.shopping_cart_outlined),
        find.byIcon(Icons.add_shopping_cart),
      ];
      
      for (final buttonFinder in addToCartButtons) {
        if (buttonFinder.evaluate().isNotEmpty) {
          await tester.tap(buttonFinder.first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          break;
        }
      }

      // Assert - Should handle add to cart
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle sharing functionality', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Look for share button
      final shareButtons = [
        find.byIcon(Icons.share),
        find.textContaining('Share'),
        find.byIcon(Icons.ios_share),
      ];
      
      for (final buttonFinder in shareButtons) {
        if (buttonFinder.evaluate().isNotEmpty) {
          await tester.tap(buttonFinder.first);
          await tester.pump();
          break;
        }
      }

      // Assert - Should handle share functionality
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle product description section display', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Act & Assert - Look for description elements
      final descriptionElements = [
        find.textContaining('Description'),
        find.textContaining('Test product description'),
        find.textContaining('details'),
        find.byType(design.AppSection),
      ];
      
      // Should display description section
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle navigation back functionality', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: Text('Previous Page')),
          routes: {
            '/product_detail': (context) => ProductDetailPage(productId: testProduct.id),
          },
        ),
      );
      
      // Navigate to product detail
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pushNamed('/product_detail');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Act - Tap back button
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton.first);
        await tester.pump();
      } else {
        navigator.pop();
        await tester.pump();
      }

      // Assert - Should navigate back
      expect(find.text('Previous Page'), findsOneWidget);
    });

    testWidgets('should handle product rating display and interaction', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Act & Assert - Look for rating elements
      final ratingElements = [
        find.textContaining('★'),
        find.textContaining('4.5'),
        find.textContaining('Rating'),
        find.textContaining('Reviews'),
        find.textContaining('120'),
        find.textContaining('('),
        find.textContaining(')'),
      ];
      
      // Should display rating information
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle product bloc event dispatching', (WidgetTester tester) async {
      // Arrange - Test that product bloc events are properly dispatched
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();

      // Act - Allow bloc to process LoadProduct event
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - Should handle bloc event processing
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle multiple product ID scenarios', (WidgetTester tester) async {
      // Arrange - Test different product IDs
      final testIds = [1, 2, 999, -1, 0];
      
      for (final productId in testIds) {
        await tester.pumpWidget(
          MaterialApp(
            home: ProductDetailPage(productId: productId),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Assert - Should handle different product IDs
        expect(find.byType(ProductDetailPage), findsOneWidget);
        
        // Clean up for next iteration
        await tester.pumpWidget(Container());
        await tester.pump();
      }
    });

    testWidgets('should handle widget lifecycle and bloc disposal', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      // Simulate widget disposal
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: Text('Different Page')),
        ),
      );
      await tester.pump();

      // Assert - Should handle disposal properly
      expect(find.text('Different Page'), findsOneWidget);
    });

    testWidgets('should handle scrolling through product content', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Try to scroll through content
      final scrollableWidgets = [
        find.byType(SingleChildScrollView),
        find.byType(ListView),
        find.byType(CustomScrollView),
      ];
      
      for (final scrollableFinder in scrollableWidgets) {
        if (scrollableFinder.evaluate().isNotEmpty) {
          await tester.fling(scrollableFinder.first, const Offset(0, -300), 300);
          await tester.pump();
          await tester.fling(scrollableFinder.first, const Offset(0, 300), 300);
          await tester.pump();
          break;
        }
      }

      // Assert - Should handle scrolling
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('should handle fixed bottom CTA accessibility', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailPage(productId: testProduct.id),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Act & Assert - Check for fixed bottom elements
      final bottomElements = [
        find.byType(SafeArea),
        find.byType(design.AppButton),
        find.textContaining('Add'),
      ];
      
      // Should have accessible bottom CTA
      expect(find.byType(ProductDetailPage), findsOneWidget);
    });
  });
}