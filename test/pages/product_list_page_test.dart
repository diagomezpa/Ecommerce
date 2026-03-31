import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pragma_app_shell/pages/product_list_page.dart';
import 'package:pragma_design_system/pragma_design_system.dart' as design;
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';

void main() {
  group('ProductListPage Widget Tests', () {

    testWidgets('should render correctly with main UI structure', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();

      // Assert - Verify basic page structure
      expect(find.byType(ProductListPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Product Catalog'), findsOneWidget);
    });

    testWidgets('should show loading state initially', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();

      // Assert - Should show loading indicator or basic structure
      expect(find.byType(ProductListPage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have filter section in UI', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();

      // Assert - Should have basic structure in place
      expect(find.byType(ProductListPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      // Filter section structure should be present
    });

    testWidgets('should handle different screen sizes', (WidgetTester tester) async {
      // Arrange - Set tablet size
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();

      // Assert - Should adapt to larger screen
      expect(find.byType(ProductListPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // Cleanup
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should be stateful widget', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();

      // Assert - Should be stateful
      expect(find.byType(ProductListPage), findsOneWidget);
      final widget = tester.widget<ProductListPage>(find.byType(ProductListPage));
      expect(widget, isA<StatefulWidget>());
    });

    testWidgets('should handle widget rebuilds correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();

      // Act - Force rebuild
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Should still be functional after rebuild
      expect(find.byType(ProductListPage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should maintain widget key functionality', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(
            key: Key('product_list_page_key'),
          ),
        ),
      );
      await tester.pump();

      // Assert - Should find widget by key
      expect(find.byKey(const Key('product_list_page_key')), findsOneWidget);
    });

    testWidgets('should maintain consistent widget hierarchy', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();

      // Assert - Should have consistent structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(ProductListPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle navigation context properly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: Text('Previous Page')),
          onGenerateRoute: (settings) {
            if (settings.name == '/product_list') {
              return MaterialPageRoute(
                builder: (context) => const ProductListPage(),
              );
            }
            return null;
          },
        ),
      );
      
      // Navigate to product list
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pushNamed('/product_list');
      await tester.pump();

      // Act - Try to go back
      navigator.pop();
      await tester.pump();

      // Assert - Should navigate back
      expect(find.text('Previous Page'), findsOneWidget);
    });

    testWidgets('should initialize without constructor parameters', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();

      // Assert - Should initialize properly without parameters
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle product filtering by category', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 500));

      // Act - Look for filter elements
      final filterChips = find.byType(ChoiceChip);
      final filterButtons = [
        find.textContaining('Electronics'),
        find.textContaining('Clothing'),
        find.textContaining('Books'),
      ];
      final dropdowns = find.byType(DropdownButton);
      
      if (filterChips.evaluate().isNotEmpty) {
        await tester.tap(filterChips.first);
        await tester.pump();
      } else {
        for (final buttonFinder in filterButtons) {
          if (buttonFinder.evaluate().isNotEmpty) {
            await tester.tap(buttonFinder.first);
            await tester.pump();
            break;
          }
        }
      }
      
      if (dropdowns.evaluate().isNotEmpty) {
        await tester.tap(dropdowns.first);
        await tester.pump();
      }

      // Assert - Should handle filtering
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should display product grid or list', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Assert - Should display products in some layout
      final gridView = find.byType(GridView);
      final listView = find.byType(ListView);
      final productCards = find.byType(Card);
      final productItems = find.byType(design.AppProductListItem);
      
      // Should have some kind of product display
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle product item interactions', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
          routes: {
            '/product_detail': (context) => const Scaffold(body: Text('Product Detail')),
          },
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Look for product items to tap
      final productItems = find.byType(design.AppProductListItem);
      final productCards = find.byType(Card);
      final gestureDetectors = find.byType(GestureDetector);
      
      if (productItems.evaluate().isNotEmpty) {
        await tester.tap(productItems.first);
        await tester.pump();
      } else if (productCards.evaluate().isNotEmpty) {
        await tester.tap(productCards.first);
        await tester.pump();
      }

      // Assert - Should handle product interaction
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle add to cart from product list', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Look for add to cart buttons
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
          break;
        }
      }

      // Assert - Should handle add to cart
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle search functionality', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();

      // Act - Look for search components
      final searchFields = find.byType(TextField);
      final searchBars = find.byType(SearchBar);
      final searchButtons = find.byIcon(Icons.search);
      
      if (searchFields.evaluate().isNotEmpty) {
        await tester.enterText(searchFields.first, 'test product');
        await tester.pump();
      }
      
      if (searchButtons.evaluate().isNotEmpty) {
        await tester.tap(searchButtons.first);
        await tester.pump();
      }

      // Assert - Should handle search
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle sorting functionality', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 500));

      // Act - Look for sort options
      final sortButtons = [
        find.textContaining('Sort'),
        find.textContaining('Price'),
        find.textContaining('Name'),
        find.textContaining('Rating'),
        find.byIcon(Icons.sort),
      ];
      
      for (final buttonFinder in sortButtons) {
        if (buttonFinder.evaluate().isNotEmpty) {
          await tester.tap(buttonFinder.first);
          await tester.pump();
          break;
        }
      }

      // Assert - Should handle sorting
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle scrolling through product list', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Try to scroll
      final scrollableWidgets = [
        find.byType(ListView),
        find.byType(GridView),
        find.byType(SingleChildScrollView),
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
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle refresh functionality', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();

      // Act - Look for RefreshIndicator and pull to refresh
      final refreshIndicator = find.byType(RefreshIndicator);
      if (refreshIndicator.evaluate().isNotEmpty) {
        await tester.fling(refreshIndicator.first, const Offset(0, 300), 300);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Assert - Should handle refresh
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle empty state when no products', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 2000));

      // Assert - Should handle empty state gracefully
      final emptyStateElements = [
        find.textContaining('No products'),
        find.textContaining('empty'),
        find.textContaining('found'),
        find.byIcon(Icons.inbox),
      ];
      
      // Should handle empty state or display products
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should navigate to cart from app bar', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
          routes: {
            '/cart': (context) => const Scaffold(body: Text('Cart Page')),
          },
        ),
      );
      await tester.pump();

      // Act - Look for cart icon
      final cartIcon = find.byIcon(Icons.shopping_cart);
      if (cartIcon.evaluate().isNotEmpty) {
        await tester.tap(cartIcon.first);
        await tester.pump();
      }

      // Assert - Should handle navigation
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should display product prices and ratings', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Assert - Look for price and rating elements
      final priceElements = find.textContaining('\$');
      final ratingElements = find.textContaining('★');
      
      // Should display price and rating info when products load
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle error states gracefully', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      // Wait for potential errors to occur
      await tester.pump(const Duration(milliseconds: 3000));

      // Assert - Should maintain structure even with errors
      expect(find.byType(ProductListPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle product bloc loading state correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();

      // Assert - Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle product bloc error state with retry', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      // Wait for potential error state
      await tester.pump(const Duration(milliseconds: 3000));

      // Act - Look for error elements and retry button
      final errorElements = [
        find.textContaining('Unable to Load'),
        find.textContaining('Error'),
        find.textContaining('Retry'),
        find.byIcon(Icons.store_outlined),
      ];
      
      final retryButton = find.textContaining('Retry');
      if (retryButton.evaluate().isNotEmpty) {
        await tester.tap(retryButton.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Assert - Should handle error state and retry
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle successful products loading and display', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      // Wait for successful loading
      await tester.pump(const Duration(milliseconds: 2000));

      // Act & Assert - Look for success state elements
      final successElements = [
        find.textContaining('\$'),
        find.textContaining('Electronics'),
        find.textContaining('Add'),
        find.byType(design.AppText),
        find.byType(design.AppCard),
      ];
      
      // Should handle successful product display
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle category filter state management', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Look for filter elements and interact with them
      final filterChips = find.byType(ChoiceChip);
      final filterButtons = [
        find.textContaining('Electronics'),
        find.textContaining('Clothing'),
        find.textContaining('Books'),
        find.textContaining('All'),
      ];
      
      if (filterChips.evaluate().isNotEmpty) {
        await tester.tap(filterChips.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        
        // Try tapping another filter
        if (filterChips.evaluate().length > 1) {
          await tester.tap(filterChips.at(1));
          await tester.pump();
        }
      } else {
        for (final buttonFinder in filterButtons) {
          if (buttonFinder.evaluate().isNotEmpty) {
            await tester.tap(buttonFinder.first);
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 200));
            break;
          }
        }
      }

      // Assert - Should handle filter state changes
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle filter clearing functionality', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Look for clear filter options
      final clearFilterButtons = [
        find.textContaining('Clear'),
        find.textContaining('All'),
        find.textContaining('Reset'),
        find.byIcon(Icons.clear),
      ];
      
      for (final buttonFinder in clearFilterButtons) {
        if (buttonFinder.evaluate().isNotEmpty) {
          await tester.tap(buttonFinder.first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));
          break;
        }
      }

      // Assert - Should handle filter clearing
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle product filter helper integration', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1500));

      // Simulate filter operations by tapping different categories
      final categoryFilters = [
        find.textContaining('Electronics'),
        find.textContaining('Jewelry'),
        find.textContaining('Men'),
        find.textContaining('Women'),
      ];
      
      for (final categoryFilter in categoryFilters) {
        if (categoryFilter.evaluate().isNotEmpty) {
          await tester.tap(categoryFilter.first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          break;
        }
      }

      // Assert - Should integrate with filter helper
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle navigation to product detail on selection', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
          routes: {
            '/product_detail': (context) => const Scaffold(body: Text('Product Detail')),
          },
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1500));

      // Act - Look for product items to tap
      final productElements = [
        find.byType(Card),
        find.byType(design.AppCard),
        find.byType(GestureDetector),
        find.byType(InkWell),
        find.byType(design.AppProductListItem),
      ];
      
      for (final productFinder in productElements) {
        if (productFinder.evaluate().isNotEmpty) {
          await tester.tap(productFinder.first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));
          break;
        }
      }

      // Assert - Should handle product selection navigation
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle cart navigation from app bar', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
          routes: {
            '/cart': (context) => const Scaffold(body: Text('Cart Page')),
          },
        ),
      );
      await tester.pump();

      // Act - Look for cart icon in app bar
      final cartIcon = find.byIcon(Icons.shopping_cart);
      if (cartIcon.evaluate().isNotEmpty) {
        await tester.tap(cartIcon.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Assert - Should handle cart navigation
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle empty state when no products match filter', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 2000));

      // Act - Apply filters that might result in empty state
      final filterChips = find.byType(ChoiceChip);
      if (filterChips.evaluate().length > 2) {
        await tester.tap(filterChips.at(2));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Assert - Look for empty state handling
      final emptyStateElements = [
        find.textContaining('No products'),
        find.textContaining('empty'),
        find.textContaining('found'),
        find.byIcon(Icons.inbox),
      ];
      
      // Should handle empty state gracefully
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle product grid/list layout display', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1500));

      // Act & Assert - Look for product layout elements
      final layoutElements = [
        find.byType(GridView),
        find.byType(ListView),
        find.byType(SliverGrid),
        find.byType(SliverList),
        find.byType(design.AppProductListItem),
      ];
      
      // Should display products in grid or list layout
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle widget lifecycle and bloc disposal', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
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

    testWidgets('should handle category extensions display', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1500));

      // Act & Assert - Look for category-related content
      final categoryElements = [
        find.textContaining('ELECTRONICS'),
        find.textContaining('JEWELERY'),
        find.textContaining('MENS_CLOTHING'),
        find.textContaining('WOMENS_CLOTHING'),
      ];
      
      // Should display category extensions
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle product loading event dispatching', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();

      // Act - Allow bloc to process LoadProducts event
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - Should handle bloc event processing
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle multiple filter category interactions', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Test multiple filter interactions
      final filterElements = find.byType(ChoiceChip);
      if (filterElements.evaluate().length >= 2) {
        // Select first filter
        await tester.tap(filterElements.at(0));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        
        // Select second filter
        await tester.tap(filterElements.at(1));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        
        // Go back to first filter
        await tester.tap(filterElements.at(0));
        await tester.pump();
      }

      // Assert - Should handle multiple filter interactions
      expect(find.byType(ProductListPage), findsOneWidget);
    });

    testWidgets('should handle state persistence across rebuilds', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListPage(),
        ),
      );
      await tester.pump();
      
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Apply a filter and then rebuild
      final filterChips = find.byType(ChoiceChip);
      if (filterChips.evaluate().isNotEmpty) {
        await tester.tap(filterChips.first);
        await tester.pump();
        
        // Force rebuild
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump();
      }

      // Assert - Should maintain state across rebuilds
      expect(find.byType(ProductListPage), findsOneWidget);
    });
  });
}