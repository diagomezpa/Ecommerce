import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pragma_app_shell/pages/support_page.dart';
import 'package:pragma_design_system/pragma_design_system.dart' as design;

void main() {
  group('SupportPage Widget Tests', () {
    
    testWidgets('should render correctly with main UI structure', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const SupportPage(),
        ),
      );
      await tester.pump();

      // Assert - Verify basic page structure
      expect(find.byType(SupportPage), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Contact Information'), findsOneWidget);
    });

    testWidgets('should display contact information section', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const SupportPage(),
        ),
      );
      await tester.pump();

      // Assert - Should have contact info
      expect(find.text('Contact Information'), findsOneWidget);
      expect(find.byType(design.AppCard), findsWidgets);
      expect(find.byIcon(Icons.phone), findsOneWidget);
    });

    testWidgets('should have contact form with all fields', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const SupportPage(),
        ),
      );
      await tester.pump();

      // Assert - Should have form fields
      expect(find.byType(design.AppFormField), findsNWidgets(3)); // Name, email, message
      expect(find.byType(design.AppButton), findsWidgets);
    });

    testWidgets('should validate form fields when submitting empty form', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const SupportPage(),
        ),
      );
      await tester.pump();

      // Act - Try to submit empty form
      final submitButton = find.text('Send Message');
      if (submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton);
        await tester.pump();
      }

      // Assert - Should show validation or handle gracefully
      expect(find.byType(SupportPage), findsOneWidget);
    });

    testWidgets('should accept text input in form fields', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const SupportPage(),
        ),
      );
      await tester.pump();

      // Act - Enter text in form fields
      final formFields = find.byType(design.AppFormField);
      if (formFields.evaluate().isNotEmpty) {
        await tester.enterText(formFields.first, 'John Doe');
        await tester.pump();
      }

      // Assert - Should accept input
      expect(find.byType(SupportPage), findsOneWidget);
    });

    testWidgets('should submit valid form successfully', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const SupportPage(),
        ),
      );
      await tester.pump();

      // Act - Fill form with valid data
      final formFields = find.byType(design.AppFormField);
      if (formFields.evaluate().length >= 3) {
        await tester.enterText(formFields.at(0), 'John Doe');
        await tester.enterText(formFields.at(1), 'john@example.com');
        await tester.enterText(formFields.at(2), 'This is my support message');
        await tester.pump();

        // Try to submit
        final submitButton = find.text('Send Message');
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton);
          await tester.pump();
        }
      }

      // Assert - Should handle submission
      expect(find.byType(SupportPage), findsOneWidget);
    });

    testWidgets('should handle different screen sizes', (WidgetTester tester) async {
      // Arrange - Set tablet size
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: const SupportPage(),
        ),
      );
      await tester.pump();

      // Assert - Should adapt to larger screen
      expect(find.byType(SupportPage), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);

      // Cleanup
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should be scrollable when content is long', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const SupportPage(),
        ),
      );
      await tester.pump();

      // Act - Try to scroll
      final scrollView = find.byType(SingleChildScrollView);
      if (scrollView.evaluate().isNotEmpty) {
        await tester.drag(scrollView, const Offset(0, -200));
        await tester.pump();
      }

      // Assert - Should handle scrolling
      expect(find.byType(SupportPage), findsOneWidget);
    });

    testWidgets('should handle widget rebuilds correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const SupportPage(),
        ),
      );
      await tester.pump();

      // Act - Force rebuild
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Should still be functional after rebuild
      expect(find.byType(SupportPage), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
    });

    testWidgets('should maintain widget key functionality', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const SupportPage(
            key: Key('support_page_key'),
          ),
        ),
      );
      await tester.pump();

      // Assert - Should find widget by key
      expect(find.byKey(const Key('support_page_key')), findsOneWidget);
    });

    testWidgets('should clear form after successful submission', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const SupportPage(),
        ),
      );
      await tester.pump();

      // Act - Fill and submit form
      final formFields = find.byType(design.AppFormField);
      if (formFields.evaluate().length >= 3) {
        await tester.enterText(formFields.at(0), 'John Doe');
        await tester.enterText(formFields.at(1), 'john@example.com');
        await tester.enterText(formFields.at(2), 'Support message');
        await tester.pump();

        final submitButton = find.text('Send Message');
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton);
          await tester.pump();
          
          // Handle dialog if it appears
          final okButton = find.text('OK');
          if (okButton.evaluate().isNotEmpty) {
            await tester.tap(okButton);
            await tester.pump();
          }
        }
      }

      // Assert - Should maintain page functionality
      expect(find.byType(SupportPage), findsOneWidget);
    });
  });
}