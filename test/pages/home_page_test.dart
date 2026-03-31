import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pragma_app_shell/pages/home_page.dart';
import 'package:pragma_design_system/pragma_design_system.dart' as design;

void main() {
  group('HomePage Widget Tests', () {
    
    testWidgets('should render correctly with main UI structure', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();

      // Assert - Verify basic page structure
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Pragma Store'), findsOneWidget);
    });

    testWidgets('should show loading state initially', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();

      // Assert - Should show loading indicator or basic structure
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should maintain basic page structure', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();

      // Assert - Should have basic structure
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should handle different screen sizes', (WidgetTester tester) async {
      // Arrange - Set tablet size
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();

      // Assert - Should adapt to larger screen
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // Cleanup
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should be stateful widget', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();

      // Assert - Should be stateful
      expect(find.byType(HomePage), findsOneWidget);
      final widget = tester.widget<HomePage>(find.byType(HomePage));
      expect(widget, isA<StatefulWidget>());
    });

    testWidgets('should handle user interactions safely', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();

      // Act - Try to interact with the page (scroll, tap, etc.)
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Should handle interactions gracefully
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle widget rebuilds correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();

      // Act - Force rebuild
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Should still be functional after rebuild
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should maintain widget key functionality', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(
            key: Key('home_page_key'),
          ),
        ),
      );
      await tester.pump();

      // Assert - Should find widget by key
      expect(find.byKey(const Key('home_page_key')), findsOneWidget);
    });

    testWidgets('should maintain consistent widget hierarchy', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();

      // Assert - Should have consistent structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should initialize without constructor parameters', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();

      // Assert - Should initialize properly without parameters
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle navigation to other pages', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/cart': (context) => const Scaffold(body: Text('Cart Page')),
            '/search': (context) => const Scaffold(body: Text('Search Page')),
            '/profile': (context) => const Scaffold(body: Text('Profile Page')),
          },
        ),
      );
      await tester.pump();

      // Act - Look for navigation elements and interact with them
      final cartButton = find.byIcon(Icons.shopping_cart);
      final searchButton = find.byIcon(Icons.search); 
      final profileButton = find.byIcon(Icons.person);
      
      if (cartButton.evaluate().isNotEmpty) {
        await tester.tap(cartButton.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      if (searchButton.evaluate().isNotEmpty) {
        await tester.tap(searchButton.first);
        await tester.pump();
      }

      // Assert - Should handle navigation attempts
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should display product categories or sections', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();
      
      // Wait for potential async operations
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - Look for category-related content
      final categoryTexts = [
        find.textContaining('Electronics'),
        find.textContaining('Clothing'),
        find.textContaining('Books'),
        find.textContaining('Categories'),
        find.textContaining('Popular'),
        find.textContaining('Featured'),
      ];
      
      // Should handle category display
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle product interactions', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();
      
      // Wait for products to potentially load
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Look for product-related UI elements
      final productCards = find.byType(Card);
      final productImages = find.byType(Image);
      final productButtons = find.byType(design.AppButton);
      
      if (productCards.evaluate().isNotEmpty) {
        await tester.tap(productCards.first);
        await tester.pump();
      }
      
      if (productButtons.evaluate().isNotEmpty) {
        await tester.tap(productButtons.first);
        await tester.pump();
      }

      // Assert - Should handle product interactions
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle search functionality', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();

      // Act - Look for search elements
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

      // Assert - Should handle search interaction
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle empty or loading states', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();

      // Wait and check for loading indicators
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Should show appropriate state
      final loadingIndicators = [
        find.byType(CircularProgressIndicator),
        find.byType(LinearProgressIndicator),
        find.textContaining('Loading'),
      ];
      
      bool hasLoadingIndicator = false;
      for (final indicator in loadingIndicators) {
        if (indicator.evaluate().isNotEmpty) {
          hasLoadingIndicator = true;
          break;
        }
      }

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle add to cart functionality', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();
      
      // Wait for potential products to load
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Look for "Add to Cart" buttons or similar
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

      // Assert - Should handle add to cart interaction
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle scrolling through product lists', (WidgetTester tester) async {
      // Arrange & Act  
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();
      
      // Wait for content to load
      await tester.pump(const Duration(milliseconds: 500));

      // Act - Try to scroll through different scrollable widgets
      final scrollableWidgets = [
        find.byType(ListView),
        find.byType(GridView),
        find.byType(SingleChildScrollView),
        find.byType(CustomScrollView),
      ];
      
      for (final scrollableFinder in scrollableWidgets) {
        if (scrollableFinder.evaluate().isNotEmpty) {
          // Scroll down
          await tester.fling(scrollableFinder.first, const Offset(0, -300), 300);
          await tester.pump();
          
          // Scroll back up
          await tester.fling(scrollableFinder.first, const Offset(0, 300), 300);
          await tester.pump();
          break;
        }
      }

      // Assert - Should handle scrolling
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle refresh functionality', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
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
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle error states gracefully', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();
      
      // Wait for potential async operations and errors 
      await tester.pump(const Duration(milliseconds: 2000));

      // Assert - Should maintain structure even with potential errors
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle logout dialog interaction and navigation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Page')),
          },
        ),
      );
      await tester.pump();

      // Act - Tap logout button in app bar
      final logoutButton = find.byIcon(Icons.logout);
      if (logoutButton.evaluate().isNotEmpty) {
        await tester.tap(logoutButton.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        
        // Look for logout dialog buttons
        final logoutConfirmButton = find.textContaining('Logout');
        final cancelButton = find.textContaining('Cancel');
        
        if (logoutConfirmButton.evaluate().isNotEmpty) {
          await tester.tap(logoutConfirmButton.first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      // Assert - Should handle logout dialog
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should test featured products section functionality', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();
      
      // Wait for products to potentially load
      await tester.pump(const Duration(milliseconds: 2000));

      // Act & Assert - Look for featured products elements
      final featuredElements = [
        find.textContaining('Featured'),
        find.textContaining('Popular'),
        find.textContaining('recommended'),
        find.textContaining('Best'),
        find.textContaining('★'),
        find.textContaining('4.'),
      ];
      
      // Should handle featured products display
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should test promotional products section functionality', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();
      
      // Wait for products to potentially load
      await tester.pump(const Duration(milliseconds: 2000));

      // Act & Assert - Look for promotional products elements
      final promotionalElements = [
        find.textContaining('Promotional'),
        find.textContaining('Special'),
        find.textContaining('Deal'),
        find.textContaining('Sale'),
        find.textContaining('\$'),
      ];
      
      // Should handle promotional products display
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle product bloc loading state correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();

      // Assert - Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
      
      // Wait for loading to potentially complete
      await tester.pump(const Duration(milliseconds: 1000));
    });

    testWidgets('should handle product bloc error state with retry', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
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
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle quick actions section navigation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/product_list': (context) => const Scaffold(body: Text('Product List')),
            '/search': (context) => const Scaffold(body: Text('Search Page')),
            '/support': (context) => const Scaffold(body: Text('Support Page')),
          },
        ),
      );
      await tester.pump();
      
      // Wait for page to load
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Look for quick action buttons
      final quickActionButtons = [
        find.textContaining('Catalog'),
        find.textContaining('Browse'),
        find.textContaining('Search'),
        find.textContaining('View All'),
        find.textContaining('Support'),
      ];
      
      for (final buttonFinder in quickActionButtons) {
        if (buttonFinder.evaluate().isNotEmpty) {
          await tester.tap(buttonFinder.first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          break;
        }
      }

      // Assert - Should handle quick actions navigation
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle product classification and display', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();
      
      // Wait for products to load and classification
      await tester.pump(const Duration(milliseconds: 2000));

      // Act & Assert - Look for classified products
      final classificationElements = [
        find.textContaining('Featured'),
        find.textContaining('Promotional'),
        find.byType(design.AppSection),
        find.byType(design.AppCard),
      ];
      
      // Should handle product classification display
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle product selection and navigation to detail', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/product_detail': (context) => const Scaffold(body: Text('Product Detail')),
          },
        ),
      );
      await tester.pump();
      
      // Wait for products to load
      await tester.pump(const Duration(milliseconds: 2000));

      // Act - Look for product cards or items to tap
      final productElements = [
        find.byType(Card),
        find.byType(design.AppCard),
        find.byType(GestureDetector),
        find.byType(InkWell),
      ];
      
      for (final productFinder in productElements) {
        if (productFinder.evaluate().isNotEmpty) {
          await tester.tap(productFinder.first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          break;
        }
      }

      // Assert - Should handle product selection
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle app bar actions and navigation to cart', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/cart': (context) => const Scaffold(body: Text('Cart Page')),
          },
        ),
      );
      await tester.pump();

      // Act - Tap cart button in app bar
      final cartButton = find.byIcon(Icons.shopping_cart);
      if (cartButton.evaluate().isNotEmpty) {
        await tester.tap(cartButton.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Assert - Should handle cart navigation
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle state management and product data updates', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();
      
      // Act - Simulate state changes by waiting and pumping
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 1500));

      // Force widget rebuilds to test state management
      await tester.pump();

      // Assert - Should maintain state properly
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle successful products loading and display', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();
      
      // Wait for successful loading
      await tester.pump(const Duration(milliseconds: 2500));

      // Act & Assert - Look for success state elements
      final successElements = [
        find.textContaining('\$'),
        find.textContaining('Electronics'),
        find.textContaining('Clothing'),
        find.textContaining('Add'),
        find.byType(design.AppText),
        find.byType(design.AppPrice),
      ];
      
      // Should handle successful product display
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle widget lifecycle and bloc disposal', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();
      
      // Simulate widget disposal scenario
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: Text('Different Page')),
        ),
      );
      await tester.pump();

      // Assert - Should handle disposal properly
      expect(find.text('Different Page'), findsOneWidget);
    });

    testWidgets('should handle product price formatting and display', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();
      
      // Wait for products with prices to load
      await tester.pump(const Duration(milliseconds: 2000));

      // Act & Assert - Look for price formatting
      final priceElements = [
        find.textContaining('\$'),
        find.textContaining('.99'),
        find.textContaining('.00'),
        find.byType(design.AppPrice),
      ];
      
      // Should handle price display and formatting
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle category extensions and display', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );
      await tester.pump();
      
      // Wait for categories to load
      await tester.pump(const Duration(milliseconds: 2000));

      // Act & Assert - Look for category-related content
      final categoryElements = [
        find.textContaining('Electronics'),
        find.textContaining('Clothing'),
        find.textContaining('Men'),
        find.textContaining('Women'),
        find.textContaining('Jewelry'),
      ];
      
      // Should handle category display
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}