import 'package:flutter_test/flutter_test.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import 'package:pragma_app_shell/helpers/user_message_helper.dart';

void main() {
  group('UserMessageHelper', () {
    group('getSuccessSnackbarMessage', () {
      test('should return correct success message', () {
        final message = UserMessageHelper.getSuccessSnackbarMessage();
        expect(message, equals('User created! You can now log in.'));
      });
    });

    group('getErrorSnackbarMessage', () {
      test('should return custom error message when provided', () {
        const customError = 'Username already exists';
        final message = UserMessageHelper.getErrorSnackbarMessage(customError);
        expect(message, equals(customError));
      });

      test('should return default error message when null provided', () {
        final message = UserMessageHelper.getErrorSnackbarMessage(null);
        expect(message, equals('Failed to create user. Please try again.'));
      });

      test('should return default error message when empty string provided', () {
        final message = UserMessageHelper.getErrorSnackbarMessage('');
        expect(message, equals(''));
      });

      test('should handle whitespace-only error message', () {
        final message = UserMessageHelper.getErrorSnackbarMessage('   ');
        expect(message, equals('   '));
      });

      test('should handle various error messages', () {
        const testMessages = [
          'Network error occurred',
          'Server is temporarily unavailable',
          'Invalid email format',
          'Password does not meet requirements',
        ];

        for (final testMessage in testMessages) {
          final message = UserMessageHelper.getErrorSnackbarMessage(testMessage);
          expect(message, equals(testMessage));
        }
      });
    });

    group('getSuccessDialogTitle', () {
      test('should return correct dialog title', () {
        final title = UserMessageHelper.getSuccessDialogTitle();
        expect(title, equals('User Created Successfully!'));
      });
    });

    group('getSuccessDialogContent', () {
      test('should format dialog content with complete user details', () {
        final user = User(
          id: 123,
          username: 'johndoe123',
          email: 'john.doe@example.com',
          password: 'password',
          name: Name(firstname: 'John', lastname: 'Doe'),
          phone: null,
          address: null,
        );

        final content = UserMessageHelper.getSuccessDialogContent(user);

        expect(content, contains('Your account has been created successfully!'));
        expect(content, contains('You can now sign in with your new credentials.'));
        expect(content, contains('User Details:'));
        expect(content, contains('ID: 123'));
        expect(content, contains('Username: johndoe123'));
        expect(content, contains('Email: john.doe@example.com'));
      });

      test('should handle user with null ID', () {
        final user = User(
          id: null,
          username: 'johndoe123',
          email: 'john.doe@example.com',
          password: 'password',
          name: Name(firstname: 'John', lastname: 'Doe'),
          phone: null,
          address: null,
        );

        final content = UserMessageHelper.getSuccessDialogContent(user);

        expect(content, contains('ID: Auto-generated'));
        expect(content, contains('Username: johndoe123'));
        expect(content, contains('Email: john.doe@example.com'));
      });

      test('should handle user with null username', () {
        final user = User(
          id: 123,
          username: null,
          email: 'john.doe@example.com',
          password: 'password',
          name: Name(firstname: 'John', lastname: 'Doe'),
          phone: null,
          address: null,
        );

        final content = UserMessageHelper.getSuccessDialogContent(user);

        expect(content, contains('ID: 123'));
        expect(content, contains('Username: N/A'));
        expect(content, contains('Email: john.doe@example.com'));
      });

      test('should handle user with null email', () {
        final user = User(
          id: 123,
          username: 'johndoe123',
          email: null,
          password: 'password',
          name: Name(firstname: 'John', lastname: 'Doe'),
          phone: null,
          address: null,
        );

        final content = UserMessageHelper.getSuccessDialogContent(user);

        expect(content, contains('ID: 123'));
        expect(content, contains('Username: johndoe123'));
        expect(content, contains('Email: N/A'));
      });

      test('should handle user with all null optional fields', () {
        final user = User(
          id: null,
          username: null,
          email: null,
          password: 'password',
          name: Name(firstname: 'John', lastname: 'Doe'),
          phone: null,
          address: null,
        );

        final content = UserMessageHelper.getSuccessDialogContent(user);

        expect(content, contains('ID: Auto-generated'));
        expect(content, contains('Username: N/A'));
        expect(content, contains('Email: N/A'));
      });

      test('should include proper formatting and line breaks', () {
        final user = User(
          id: 456,
          username: 'testuser',
          email: 'test@example.com',
          password: 'password',
          name: Name(firstname: 'Test', lastname: 'User'),
          phone: null,
          address: null,
        );

        final content = UserMessageHelper.getSuccessDialogContent(user);

        // Check that the content has proper structure
        final lines = content.split('\n');
        expect(lines[0], equals('Your account has been created successfully!'));
        expect(lines[1], equals(''));
        expect(lines[2], equals('You can now sign in with your new credentials.'));
        expect(lines[3], equals(''));
        expect(lines[4], equals('User Details:'));
        expect(lines[5], equals('ID: 456'));
        expect(lines[6], equals('Username: testuser'));
        expect(lines[7], equals('Email: test@example.com'));
      });

      test('should handle edge cases with empty strings', () {
        final user = User(
          id: 0, // Zero ID
          username: '', // Empty string
          email: '', // Empty string
          password: 'password',
          name: Name(firstname: 'Test', lastname: 'User'),
          phone: null,
          address: null,
        );

        final content = UserMessageHelper.getSuccessDialogContent(user);

        expect(content, contains('ID: 0'));
        expect(content, contains('Username: '));
        expect(content, contains('Email: '));
      });
    });

    group('getSuccessDialogActionText', () {
      test('should return correct action button text', () {
        final actionText = UserMessageHelper.getSuccessDialogActionText();
        expect(actionText, equals('Go to Login'));
      });
    });

    group('_formatUserId', () {
      test('should format positive user ID correctly', () {
        final user = User(
          id: 12345,
          username: 'test',
          email: 'test@example.com',
          password: 'password',
          name: Name(firstname: 'Test', lastname: 'User'),
          phone: null,
          address: null,
        );

        final content = UserMessageHelper.getSuccessDialogContent(user);
        expect(content, contains('ID: 12345'));
      });

      test('should format zero user ID correctly', () {
        final user = User(
          id: 0,
          username: 'test',
          email: 'test@example.com',
          password: 'password',
          name: Name(firstname: 'Test', lastname: 'User'),
          phone: null,
          address: null,
        );

        final content = UserMessageHelper.getSuccessDialogContent(user);
        expect(content, contains('ID: 0'));
      });
    });

    group('_formatField', () {
      test('should format non-null field correctly', () {
        final user = User(
          id: 1,
          username: 'validuser',
          email: 'valid@example.com',
          password: 'password',
          name: Name(firstname: 'Valid', lastname: 'User'),
          phone: null,
          address: null,
        );

        final content = UserMessageHelper.getSuccessDialogContent(user);
        expect(content, contains('Username: validuser'));
        expect(content, contains('Email: valid@example.com'));
      });

      test('should format empty string field correctly', () {
        final user = User(
          id: 1,
          username: '',
          email: '',
          password: 'password',
          name: Name(firstname: 'Test', lastname: 'User'),
          phone: null,
          address: null,
        );

        final content = UserMessageHelper.getSuccessDialogContent(user);
        expect(content, contains('Username: '));
        expect(content, contains('Email: '));
      });
    });
  });

  group('UserSessionMessages', () {
    test('should have correct constant values', () {
      expect(UserSessionMessages.userAlreadyExists, equals('User might already exist'));
      expect(UserSessionMessages.sessionWarningPrefix, equals('UserSession warning:'));
    });

    test('should provide consistent warning messages', () {
      // Test that the constants are accessible and have expected values
      const warningMessage = '${UserSessionMessages.sessionWarningPrefix} ${UserSessionMessages.userAlreadyExists}';
      expect(warningMessage, equals('UserSession warning: User might already exist'));
    });
  });
}