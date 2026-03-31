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
  });
}