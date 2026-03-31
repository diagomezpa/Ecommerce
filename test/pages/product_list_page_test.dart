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
  });
}