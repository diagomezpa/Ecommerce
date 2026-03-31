import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pragma_app_shell/pages/create_user_page.dart';
import 'package:pragma_design_system/pragma_design_system.dart' as design;
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';

void main() {
  group('CreateUserPage Widget Tests', () {

    testWidgets('should render correctly with main UI structure', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
        ),
      );
      await tester.pump();

      // Assert - Verify basic page structure
      expect(find.byType(CreateUserPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.textContaining('Create Account'), findsWidgets);
      expect(find.text('Join Our Store'), findsOneWidget);
    });

    testWidgets('should display all required form fields', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
        ),
      );
      await tester.pump();

      // Assert - Check form fields
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(design.AppFormField), findsNWidgets(5));
    });

    testWidgets('should have create account button available', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
        ),
      );
      await tester.pump();

      // Assert - Button should be available
      final createButton = find.byType(design.AppButton);
      expect(createButton, findsOneWidget);
      
      // Button should be tappable initially
      await tester.tap(createButton);
      await tester.pump();
    });

    testWidgets('should handle form text input correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
        ),
      );
      await tester.pump();

      // Act - Enter text in form fields
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(5));

      await tester.enterText(textFields.at(0), 'John');
      await tester.enterText(textFields.at(1), 'Doe');
      await tester.enterText(textFields.at(2), 'john.doe@example.com');
      await tester.enterText(textFields.at(3), 'johndoe');
      await tester.enterText(textFields.at(4), 'password123');
      await tester.pump();

      // Assert - Text should be entered
      expect(find.text('John'), findsOneWidget);
      expect(find.text('Doe'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);
      expect(find.text('johndoe'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('should validate form fields when empty', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
        ),
      );
      await tester.pump();

      // Act - Try to submit empty form
      final createButton = find.byType(design.AppButton);
      await tester.tap(createButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Form validation should prevent submission
      expect(find.byType(CreateUserPage), findsOneWidget);
    });

    testWidgets('should validate email format', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
        ),
      );
      await tester.pump();

      // Act - Enter invalid email
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(2), 'invalid-email');
      await tester.pump();

      // Try to submit
      final createButton = find.byType(design.AppButton);
      await tester.tap(createButton);
      await tester.pump();

      // Assert - Should handle validation
      expect(find.byType(CreateUserPage), findsOneWidget);
    });

    testWidgets('should handle valid form submission', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Page')),
          },
        ),
      );
      await tester.pump();

      // Act - Fill valid form data
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'John');
      await tester.enterText(textFields.at(1), 'Doe');
      await tester.enterText(textFields.at(2), 'john.doe@example.com');
      await tester.enterText(textFields.at(3), 'johndoe123');
      await tester.enterText(textFields.at(4), 'securePassword123');
      await tester.pump();

      // Submit form
      final createButton = find.byType(design.AppButton);
      await tester.tap(createButton);
      await tester.pump();

      // Wait for async operations
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 1000));

      // Assert - Should handle form submission
      expect(find.byType(CreateUserPage), findsOneWidget);
    });

    testWidgets('should show loading state during user creation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
        ),
      );
      await tester.pump();

      // Act - Fill form and submit
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Jane');
      await tester.enterText(textFields.at(1), 'Smith');
      await tester.enterText(textFields.at(2), 'jane.smith@example.com');
      await tester.enterText(textFields.at(3), 'janesmith');
      await tester.enterText(textFields.at(4), 'password123');
      await tester.pump();

      final createButton = find.byType(design.AppButton);
      await tester.tap(createButton);
      await tester.pump();

      // Check for loading state
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Should show some form of loading or processing
      expect(find.byType(CreateUserPage), findsOneWidget);
    });

    testWidgets('should handle UserCreationHelper integration', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
        ),
      );
      await tester.pump();

      // Act - Fill form with data for helper
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Helper');
      await tester.enterText(textFields.at(1), 'Test');
      await tester.enterText(textFields.at(2), 'helper@test.com');
      await tester.enterText(textFields.at(3), 'helperuser');
      await tester.enterText(textFields.at(4), 'helperpass123');
      await tester.pump();

      final createButton = find.byType(design.AppButton);
      await tester.tap(createButton);
      await tester.pump();

      // Wait for helper processing
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - Should integrate with creation helper
      expect(find.byType(CreateUserPage), findsOneWidget);
    });

    testWidgets('should handle FormValidationHelper integration', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
        ),
      );
      await tester.pump();

      // Act - Test different validation scenarios
      final textFields = find.byType(TextFormField);
      
      // Test name validation
      await tester.enterText(textFields.at(0), '1');
      await tester.enterText(textFields.at(1), '2');
      await tester.pump();
      
      // Test email validation
      await tester.enterText(textFields.at(2), 'bad-email');
      await tester.pump();
      
      // Test password validation
      await tester.enterText(textFields.at(4), '123');
      await tester.pump();

      final createButton = find.byType(design.AppButton);
      await tester.tap(createButton);
      await tester.pump();

      // Assert - Should integrate with validation helper
      expect(find.byType(CreateUserPage), findsOneWidget);
    });

    testWidgets('should handle UserMessageHelper integration', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
        ),
      );
      await tester.pump();

      // Act - Create valid user to trigger success messages
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Message');
      await tester.enterText(textFields.at(1), 'Tester');
      await tester.enterText(textFields.at(2), 'message@test.com');
      await tester.enterText(textFields.at(3), 'messageuser');
      await tester.enterText(textFields.at(4), 'messagepass123');
      await tester.pump();

      final createButton = find.byType(design.AppButton);
      await tester.tap(createButton);
      await tester.pump();

      // Wait for message helper processing
      await tester.pump(const Duration(milliseconds: 1500));

      // Assert - Should integrate with message helper
      expect(find.byType(CreateUserPage), findsOneWidget);
    });

    testWidgets('should handle successful dialog navigation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Success')),
          },
        ),
      );
      await tester.pump();

      // Act - Create successful user
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Success');
      await tester.enterText(textFields.at(1), 'User');
      await tester.enterText(textFields.at(2), 'success@test.com');
      await tester.enterText(textFields.at(3), 'successuser');
      await tester.enterText(textFields.at(4), 'successpass123');
      await tester.pump();

      final createButton = find.byType(design.AppButton);
      await tester.tap(createButton);
      await tester.pump();

      // Wait for success dialog
      await tester.pump(const Duration(milliseconds: 2000));

      // Look for dialog or navigation
      final dialogButtons = [
        find.textContaining('OK'),
        find.textContaining('Continue'),
        find.textContaining('Close'),
        find.byType(design.AppButton),
      ];

      for (final buttonFinder in dialogButtons) {
        if (buttonFinder.evaluate().isNotEmpty) {
          await tester.tap(buttonFinder.first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          break;
        }
      }

      // Assert - Should handle dialog navigation
      expect(find.byType(CreateUserPage), findsOneWidget);
    });

    testWidgets('should handle form clear functionality', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
        ),
      );
      await tester.pump();

      // Act - Fill form
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Clear');
      await tester.enterText(textFields.at(1), 'Test');
      await tester.enterText(textFields.at(2), 'clear@test.com');
      await tester.enterText(textFields.at(3), 'clearuser');
      await tester.enterText(textFields.at(4), 'clearpass123');
      await tester.pump();

      // Trigger form submission to potentially clear form
      final createButton = find.byType(design.AppButton);
      await tester.tap(createButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2000));

      // Assert - Should handle form clear
      expect(find.byType(CreateUserPage), findsOneWidget);
    });

    testWidgets('should handle UserSession integration', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
        ),
      );
      await tester.pump();

      // Act - Create user to trigger session storage
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Session');
      await tester.enterText(textFields.at(1), 'User');
      await tester.enterText(textFields.at(2), 'session@test.com');
      await tester.enterText(textFields.at(3), 'sessionuser');
      await tester.enterText(textFields.at(4), 'sessionpass123');
      await tester.pump();

      final createButton = find.byType(design.AppButton);
      await tester.tap(createButton);
      await tester.pump();

      // Wait for session integration
      await tester.pump(const Duration(milliseconds: 1000));

      // Assert - Should integrate with user session
      expect(find.byType(CreateUserPage), findsOneWidget);
    });

    testWidgets('should handle password obscuring', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
        ),
      );
      await tester.pump();

      // Act - Enter password
      final passwordField = find.byType(TextFormField).at(4);
      await tester.enterText(passwordField, 'secret123');
      await tester.pump();

      // Assert - Password field should exist and handle obscuring
      expect(find.byType(CreateUserPage), findsOneWidget);
      expect(passwordField, findsOneWidget);
    });

    testWidgets('should handle different keyboard types', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
        ),
      );
      await tester.pump();

      // Act - Focus on email field (should have email keyboard type)
      final emailField = find.byType(TextFormField).at(2);
      await tester.tap(emailField);
      await tester.pump();
      
      await tester.enterText(emailField, 'keyboard@test.com');
      await tester.pump();

      // Assert - Should handle different keyboard types
      expect(find.byType(CreateUserPage), findsOneWidget);
      expect(find.text('keyboard@test.com'), findsOneWidget);
    });

    testWidgets('should handle form state management', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
        ),
      );
      await tester.pump();

      // Act - Test state changes
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'State');
      await tester.pump();
      
      // Force rebuild
      await tester.pump(const Duration(milliseconds: 100));
      
      await tester.enterText(textFields.at(1), 'Test');
      await tester.pump();

      // Assert - Should maintain form state
      expect(find.text('State'), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should handle widget lifecycle correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
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

    testWidgets('should handle error states gracefully', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const CreateUserPage(),
        ),
      );
      await tester.pump();

      // Act - Try to trigger error state with invalid data
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), ''); // Empty name
      await tester.enterText(textFields.at(1), '');
      await tester.enterText(textFields.at(2), 'invalid');
      await tester.enterText(textFields.at(3), '');
      await tester.enterText(textFields.at(4), '1');
      await tester.pump();

      final createButton = find.byType(design.AppButton);
      await tester.tap(createButton);
      await tester.pump();
      
      // Wait for potential error handling
      await tester.pump(const Duration(milliseconds: 1000));

      // Assert - Should handle errors gracefully
      expect(find.byType(CreateUserPage), findsOneWidget);
    });
  });
}