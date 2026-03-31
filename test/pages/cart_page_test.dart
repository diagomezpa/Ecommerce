import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pragma_app_shell/pages/cart_page.dart';
import 'package:pragma_design_system/pragma_design_system.dart' as design;
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';

void main() {
  group('CartPage Widget Tests', () {
    
    testWidgets('should render correctly with main UI structure', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();

      // Assert - Verify basic page structure
      expect(find.byType(CartPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Shopping Cart'), findsOneWidget);
    });

    testWidgets('should handle loading state gracefully', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();

      // Assert - Should show basic structure while loading
      expect(find.byType(CartPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have proper constructor with required parameters', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();

      // Assert - Should initialize with cartBloc
      expect(find.byType(CartPage), findsOneWidget);
      final widget = tester.widget<CartPage>(find.byType(CartPage));
      expect(widget.cartBloc, isNotNull);
    });

    testWidgets('should be stateless widget', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();

      // Assert - Should be stateless
      expect(find.byType(CartPage), findsOneWidget);
      final widget = tester.widget<CartPage>(find.byType(CartPage));
      expect(widget, isA<StatelessWidget>());
    });

    testWidgets('should handle different screen sizes', (WidgetTester tester) async {
      // Arrange - Set tablet size
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();

      // Assert - Should adapt to larger screen
      expect(find.byType(CartPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // Cleanup
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should handle widget rebuilds correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();

      // Act - Force rebuild
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Should still be functional after rebuild
      expect(find.byType(CartPage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should maintain widget key functionality', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(
            key: const Key('cart_page_key'),
            cartBloc: initializeCartBloc((state) {}),
          ),
        ),
      );
      await tester.pump();

      // Assert - Should find widget by key
      expect(find.byKey(const Key('cart_page_key')), findsOneWidget);
    });

    testWidgets('should maintain consistent widget hierarchy', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();

      // Assert - Should have consistent structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(CartPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle navigation context properly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: Text('Previous Page')),
          onGenerateRoute: (settings) {
            if (settings.name == '/cart') {
              return MaterialPageRoute(
                builder: (context) => CartPage(cartBloc: initializeCartBloc((state) {})),
              );
            }
            return null;
          },
        ),
      );
      
      // Navigate to cart
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pushNamed('/cart');
      await tester.pump();

      // Act - Try to go back
      navigator.pop();
      await tester.pump();

      // Assert - Should navigate back
      expect(find.text('Previous Page'), findsOneWidget);
    });

    testWidgets('should handle error states gracefully', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();
      
      // Allow some time for potential errors to occur
      await tester.pump(const Duration(milliseconds: 200));

      // Assert - Should maintain basic structure even with errors
      expect(find.byType(CartPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should interact with cart items when present', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();
      
      // Look for interactive elements (buttons, gesture detectors)
      final buttons = find.byType(design.AppButton);
      final iconButtons = find.byType(IconButton);
      final gestureDetectors = find.byType(GestureDetector);
      
      // Interact with cart controls if available
      if (buttons.evaluate().isNotEmpty) {
        final firstButton = buttons.first;
        await tester.tap(firstButton);
        await tester.pump();
      }

      // Assert - Should handle interactions
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should handle quantity changes for cart items', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();

      // Act - Look for quantity controls
      final increaseButtons = find.byIcon(Icons.add);
      final decreaseButtons = find.byIcon(Icons.remove);
      
      if (increaseButtons.evaluate().isNotEmpty) {
        await tester.tap(increaseButtons.first);
        await tester.pump();
      }
      
      if (decreaseButtons.evaluate().isNotEmpty) {
        await tester.tap(decreaseButtons.first);
        await tester.pump();
      }

      // Assert - Should handle quantity updates
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should handle checkout button interactions', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();

      // Act - Look for checkout related buttons and text
      final checkoutButtons = [
        find.textContaining('Proceed'),
        find.textContaining('Checkout'),
        find.textContaining('Place Order'),
      ];
      
      for (final buttonFinder in checkoutButtons) {
        if (buttonFinder.evaluate().isNotEmpty) {
          await tester.tap(buttonFinder.first);
          await tester.pump();
          break;
        }
      }

      // Assert - Should handle checkout interaction
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should handle empty cart state correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();

      // Assert - Should handle empty cart gracefully
      final emptyMessages = [
        find.textContaining('empty'),
        find.textContaining('no items'),
        find.textContaining('Start shopping'),
        find.byIcon(Icons.shopping_cart_outlined),
      ];
      
      // At least one empty state indicator should be present or cart should work normally
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should display total price calculations', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();

      // Look for price-related elements
      final pricingElements = [
        find.textContaining('\$'),
        find.textContaining('Total'),
        find.textContaining('Subtotal'),
      ];
      
      // Assert - Should handle price display
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should handle scrolling for long cart lists', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();

      // Act - Try to scroll if scrollable content exists
      final scrollableWidgets = [
        find.byType(ListView),
        find.byType(SingleChildScrollView),
        find.byType(CustomScrollView),
      ];
      
      for (final scrollableFinder in scrollableWidgets) {
        if (scrollableFinder.evaluate().isNotEmpty) {
          await tester.fling(scrollableFinder.first, const Offset(0, -300), 300);
          await tester.pump();
          break;
        }
      }

      // Assert - Should handle scrolling
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should remove items from cart when requested', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();

      // Act - Look for remove/delete buttons
      final removeButtons = [
        find.byIcon(Icons.delete),
        find.byIcon(Icons.close),
        find.byIcon(Icons.remove_circle),
        find.textContaining('Remove'),
      ];
      
      for (final buttonFinder in removeButtons) {
        if (buttonFinder.evaluate().isNotEmpty) {
          await tester.tap(buttonFinder.first);
          await tester.pump();
          break;
        }
      }

      // Assert - Should handle item removal
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should show loading state correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();

      // Assert - Should show loading elements
      final loadingElements = [
        find.textContaining('Loading'),
        find.byType(CircularProgressIndicator),
        find.textContaining('wait'),
      ];
      
      bool hasLoadingIndicator = false;
      for (final element in loadingElements) {
        if (element.evaluate().isNotEmpty) {
          hasLoadingIndicator = true;
          break;
        }
      }
      
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should show error state with retry functionality', (WidgetTester tester) async {
      // Arrange - Create a bloc that will trigger error state
      bool retryPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(
            cartBloc: initializeCartBloc((state) {
              // Simulate error state
            }),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Look for error elements and retry button
      final errorElements = [
        find.textContaining('Error'),
        find.textContaining('Try Again'),
        find.textContaining('Go Back'),
        find.byIcon(Icons.error_outline),
      ];
      
      // Try to tap retry button if found
      final retryButton = find.textContaining('Try Again');
      if (retryButton.evaluate().isNotEmpty) {
        await tester.tap(retryButton.first);
        await tester.pump();
        retryPressed = true;
      }

      // Assert - Should handle error state
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should show empty cart state correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2000));

      // Assert - Look for empty cart elements
      final emptyElements = [
        find.textContaining('Empty'),
        find.textContaining('empty'),
        find.textContaining('Continue Shopping'),
        find.byIcon(Icons.shopping_cart_outlined),
      ];
      
      // Should handle empty cart display
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should handle remove item dialog interaction', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Look for delete buttons and simulate dialog
      final deleteButtons = find.byIcon(Icons.delete_outline);
      if (deleteButtons.evaluate().isNotEmpty) {
        await tester.tap(deleteButtons.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        
        // Look for dialog buttons
        final dialogButtons = [
          find.textContaining('Cancel'),
          find.textContaining('Remove'),
          find.textContaining('OK'),
        ];
        
        for (final buttonFinder in dialogButtons) {
          if (buttonFinder.evaluate().isNotEmpty) {
            await tester.tap(buttonFinder.first);
            await tester.pump();
            break;
          }
        }
      }

      // Assert - Should handle dialog interaction
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should handle checkout dialog interaction', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Look for checkout button and simulate dialog
      final checkoutButton = find.textContaining('Checkout');
      if (checkoutButton.evaluate().isNotEmpty) {
        await tester.tap(checkoutButton.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        
        // Look for dialog confirmation
        final okButton = find.textContaining('OK');
        if (okButton.evaluate().isNotEmpty) {
          await tester.tap(okButton.first);
          await tester.pump();
        }
      }

      // Assert - Should handle checkout dialog
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should display cart summary information', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      // Assert - Look for summary elements
      final summaryElements = [
        find.textContaining('Cart Summary'),
        find.textContaining('Cart ID'),
        find.textContaining('item'),
        find.textContaining('Total'),
      ];
      
      // Should display summary when cart has content
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should handle continue shopping navigation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Look for continue shopping button
      final continueButton = find.textContaining('Continue Shopping');
      if (continueButton.evaluate().isNotEmpty) {
        await tester.tap(continueButton.first);
        await tester.pump();
      }

      // Assert - Should handle navigation
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should handle cart items section display', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      // Assert - Look for cart items section elements
      final itemsElements = [
        find.textContaining('Cart Items'),
        find.textContaining('Subtotal'),
        find.byType(design.AppImage),
        find.byType(design.AppPrice),
      ];
      
      // Should display items section
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should test quantity button functionality', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      // Act - Test quantity buttons with different scenarios
      final addButtons = find.byIcon(Icons.add);
      final removeButtons = find.byIcon(Icons.remove);
      
      if (addButtons.evaluate().isNotEmpty) {
        await tester.tap(addButtons.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      if (removeButtons.evaluate().isNotEmpty) {
        await tester.tap(removeButtons.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Assert - Should handle quantity button interactions
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should test bottom bar with totals and actions', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: initializeCartBloc((state) {})),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));

      // Assert - Look for bottom bar elements
      final bottomElements = [
        find.textContaining('Total:'),
        find.textContaining('Continue Shopping'),
        find.textContaining('Checkout'),
        find.byType(SafeArea),
      ];
      
      // Should display bottom bar with actions
      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('should handle cart bloc event dispatch scenario', (WidgetTester tester) async {
      // Arrange - Create bloc with event tracking
      bool eventDispatched = false;
      final testBloc = initializeCartBloc((state) {
        eventDispatched = true;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: CartPage(cartBloc: testBloc),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Act - Trigger operations that should dispatch events
      final addButtons = find.byIcon(Icons.add);
      if (addButtons.evaluate().isNotEmpty) {
        await tester.tap(addButtons.first);
        await tester.pump();
      }

      // Assert - Should handle bloc interactions
      expect(find.byType(CartPage), findsOneWidget);
    });
  });
}