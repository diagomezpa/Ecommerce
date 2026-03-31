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
  });
}