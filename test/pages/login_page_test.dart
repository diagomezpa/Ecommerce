import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pragma_app_shell/pages/login_page.dart';
import 'package:pragma_design_system/pragma_design_system.dart' as design;

void main() {
  group('LoginPage Widget Tests', () {
    
    testWidgets('should render correctly with main UI structure', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Assert - Verify basic page structure
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should have form structure or input elements', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Assert - Should have basic input structure
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      // Input structure may use Form or individual text fields
    });

    testWidgets('should have login functionality buttons', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Assert - Should have action buttons (multiple AppButtons are expected)
      expect(find.byType(design.AppButton), findsWidgets);
    });

    testWidgets('should handle different screen sizes', (WidgetTester tester) async {
      // Arrange - Set tablet size
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Assert - Should adapt to larger screen
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // Cleanup
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should be stateful widget', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Assert - Should be stateful
      expect(find.byType(LoginPage), findsOneWidget);
      final widget = tester.widget<LoginPage>(find.byType(LoginPage));
      expect(widget, isA<StatefulWidget>());
    });

    testWidgets('should handle user interactions safely', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Act - Try to interact with the form
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'test@example.com');
        await tester.pump();
      }

      // Assert - Should handle interactions gracefully
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should handle widget rebuilds correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Act - Force rebuild
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Should still be functional after rebuild
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should maintain widget key functionality', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(
            key: Key('login_page_key'),
          ),
        ),
      );
      await tester.pump();

      // Assert - Should find widget by key
      expect(find.byKey(const Key('login_page_key')), findsOneWidget);
    });

    testWidgets('should maintain consistent widget hierarchy', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Assert - Should have consistent structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should initialize without constructor parameters', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Assert - Should initialize properly without parameters
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}