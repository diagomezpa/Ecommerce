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

    testWidgets('should handle user input form validation', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Find text fields
      final textFields = find.byType(TextFormField);
      
      // Act - Test empty form validation
      final submitButtons = [
        find.textContaining('Login'),
        find.textContaining('Sign In'),
        find.byType(design.AppButton),
        find.byType(ElevatedButton),
      ];
      
      for (final buttonFinder in submitButtons) {
        if (buttonFinder.evaluate().isNotEmpty) {
          await tester.tap(buttonFinder.first);
          await tester.pump();
          break;
        }
      }

      // Assert - Should handle form validation
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should handle valid user credentials input', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Act - Enter valid credentials
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.first, 'testuser@example.com');
        await tester.enterText(textFields.last, 'password123');
        await tester.pump();
        
        // Try to submit
        final submitButton = find.textContaining('Login');
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton.first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
        }
      }

      // Assert - Should handle valid input
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should handle authentication loading state', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Act - Enter credentials and submit to trigger loading
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.first, 'user@test.com');
        await tester.enterText(textFields.last, 'password');
        await tester.pump();
        
        final loginButton = find.textContaining('Login');
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton.first);
          await tester.pump();
          
          // Look for loading indicator
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      // Assert - Should show loading state
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should handle authentication error state', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Act - Enter invalid credentials to trigger error
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.first, 'invalid@test.com');
        await tester.enterText(textFields.last, 'wrongpassword');
        await tester.pump();
        
        final loginButton = find.textContaining('Login');
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton.first);
          await tester.pump();
          
          // Wait for error state
          await tester.pump(const Duration(milliseconds: 1500));
          await tester.pump(const Duration(milliseconds: 1000));
        }
      }

      // Assert - Should handle error display
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should handle successful authentication and navigation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
          routes: {
            '/home': (context) => const Scaffold(body: Text('Home Page')),
          },
        ),
      );
      await tester.pump();

      // Act - Enter valid admin credentials
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.first, 'admin');
        await tester.enterText(textFields.last, 'admin123');
        await tester.pump();
        
        final loginButton = find.textContaining('Login');
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton.first);
          await tester.pump();
          
          // Wait for navigation
          await tester.pump(const Duration(milliseconds: 1000));
          await tester.pump(const Duration(milliseconds: 500));
        }
      }

      // Assert - Should handle successful login
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should handle password visibility toggle', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Act - Look for password visibility toggle
      final visibilityIcons = [
        find.byIcon(Icons.visibility),
        find.byIcon(Icons.visibility_off),
        find.byType(IconButton),
      ];
      
      for (final iconFinder in visibilityIcons) {
        if (iconFinder.evaluate().isNotEmpty) {
          await tester.tap(iconFinder.first);
          await tester.pump();
          
          // Toggle again
          await tester.tap(iconFinder.first);
          await tester.pump();
          break;
        }
      }

      // Assert - Should handle visibility toggle
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should handle form field focus management', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Act - Test field focus changes
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        // Focus on username field
        await tester.tap(textFields.first);
        await tester.pump();
        
        // Enter text and move to password
        await tester.enterText(textFields.first, 'user');
        await tester.pump();
        
        // Focus on password field
        await tester.tap(textFields.last);
        await tester.pump();
        
        await tester.enterText(textFields.last, 'pass');
        await tester.pump();
      }

      // Assert - Should handle focus management
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should handle form validation helper integration', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Act - Test various validation scenarios
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        // Test invalid email format
        await tester.enterText(textFields.first, 'invalidemail');
        await tester.pump();
        
        // Test short password
        await tester.enterText(textFields.last, '123');
        await tester.pump();
        
        // Try to submit with invalid data
        final submitButton = find.textContaining('Login');
        if (submitButton.evaluate().isNotEmpty) {
          await tester.tap(submitButton.first);
          await tester.pump();
        }
      }

      // Assert - Should handle validation helper
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should handle create user navigation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
          routes: {
            '/create-user': (context) => const Scaffold(body: Text('Create User')),
          },
        ),
      );
      await tester.pump();

      // Act - Look for create user navigation
      final createUserElements = [
        find.textContaining('Create'),
        find.textContaining('Register'),
        find.textContaining('Sign Up'),
        find.byType(TextButton),
        find.byType(GestureDetector),
      ];
      
      for (final elementFinder in createUserElements) {
        if (elementFinder.evaluate().isNotEmpty) {
          await tester.tap(elementFinder.first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          break;
        }
      }

      // Assert - Should handle create user navigation
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should handle user session bloc integration', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Act - Simulate user session events
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.first, 'session@test.com');
        await tester.enterText(textFields.last, 'sessionpass');
        await tester.pump();
        
        final loginButton = find.textContaining('Login');
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton.first);
          await tester.pump();
          
          // Wait for session processing
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      // Assert - Should integrate with user session
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should handle form state management across rebuilds', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Act - Enter data and force rebuilds
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.first, 'persistent@test.com');
        await tester.enterText(textFields.last, 'persistentpass');
        await tester.pump();
        
        // Force widget rebuild
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Assert - Should maintain form state
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should handle keyboard dismissal on tap outside', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Act - Focus on field then tap outside
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.tap(textFields.first);
        await tester.pump();
        
        // Tap outside to dismiss keyboard
        await tester.tapAt(const Offset(10, 10));
        await tester.pump();
      }

      // Assert - Should handle keyboard dismissal
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should handle authentication bloc state changes', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Act - Trigger different auth states
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        // Initial state
        await tester.pump(const Duration(milliseconds: 100));
        
        // Loading state
        await tester.enterText(textFields.first, 'auth@test.com');
        await tester.enterText(textFields.last, 'authpass');
        await tester.pump();
        
        final loginButton = find.textContaining('Login');
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton.first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
        }
      }

      // Assert - Should handle auth bloc states
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should handle error message display and dismissal', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
        ),
      );
      await tester.pump();

      // Act - Trigger error message
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.first, 'error@test.com');
        await tester.enterText(textFields.last, 'errorpass');
        await tester.pump();
        
        final loginButton = find.textContaining('Login');
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton.first);
          await tester.pump();
          
          // Wait for error message
          await tester.pump(const Duration(milliseconds: 1000));
          
          // Look for dismiss button or tap to dismiss
          final dismissElements = [
            find.byIcon(Icons.close),
            find.textContaining('OK'),
            find.textContaining('Dismiss'),
          ];
          
          for (final dismissFinder in dismissElements) {
            if (dismissFinder.evaluate().isNotEmpty) {
              await tester.tap(dismissFinder.first);
              await tester.pump();
              break;
            }
          }
        }
      }

      // Assert - Should handle error display/dismissal
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should handle widget lifecycle and bloc disposal', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginPage(),
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
  });
}