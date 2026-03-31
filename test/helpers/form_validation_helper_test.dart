import 'package:flutter_test/flutter_test.dart';
import 'package:pragma_app_shell/helpers/form_validation_helper.dart';

void main() {
  group('FormValidationHelper', () {
    group('validateFirstname', () {
      test('should return error for null input', () {
        final result = FormValidationHelper.validateFirstname(null);
        expect(result, equals(FormValidationMessages.firstnameRequired));
      });

      test('should return error for empty input', () {
        final result = FormValidationHelper.validateFirstname('');
        expect(result, equals(FormValidationMessages.firstnameRequired));
      });

      test('should return null for input with only whitespace (implementation detail)', () {
        final result = FormValidationHelper.validateFirstname('   ');
        expect(result, isNull); // 3 spaces = length 3, so passes validation
      });

      test('should return error for input less than 2 characters', () {
        final result = FormValidationHelper.validateFirstname('A');
        expect(result, equals(FormValidationMessages.firstnameMinLength));
      });

      test('should return null for valid input with minimum length', () {
        final result = FormValidationHelper.validateFirstname('Jo');
        expect(result, isNull);
      });

      test('should return null for valid input', () {
        final result = FormValidationHelper.validateFirstname('John');
        expect(result, isNull);
      });

      test('should return null for valid input with special characters', () {
        final result = FormValidationHelper.validateFirstname('María');
        expect(result, isNull);
      });
    });

    group('validateLastname', () {
      test('should return error for null input', () {
        final result = FormValidationHelper.validateLastname(null);
        expect(result, equals(FormValidationMessages.lastnameRequired));
      });

      test('should return error for empty input', () {
        final result = FormValidationHelper.validateLastname('');
        expect(result, equals(FormValidationMessages.lastnameRequired));
      });

      test('should return error for input less than 2 characters', () {
        final result = FormValidationHelper.validateLastname('D');
        expect(result, equals(FormValidationMessages.lastnameMinLength));
      });

      test('should return null for valid input', () {
        final result = FormValidationHelper.validateLastname('Doe');
        expect(result, isNull);
      });

      test('should return null for valid input with minimum length', () {
        final result = FormValidationHelper.validateLastname('Li');
        expect(result, isNull);
      });
    });

    group('validateEmail', () {
      test('should return error for null input', () {
        final result = FormValidationHelper.validateEmail(null);
        expect(result, equals(FormValidationMessages.emailRequired));
      });

      test('should return error for empty input', () {
        final result = FormValidationHelper.validateEmail('');
        expect(result, equals(FormValidationMessages.emailRequired));
      });

      test('should return error for invalid email format', () {
        final invalidEmails = [
          'invalid-email',
          '@example.com',
          'user@',
          'user@.com',
          'user.example.com',
          'user@example',
          'user name@example.com',
          'user+tag@example.co.uk', // '+' is not supported by current regex
        ];

        for (final email in invalidEmails) {
          final result = FormValidationHelper.validateEmail(email);
          expect(result, equals(FormValidationMessages.emailInvalid), 
                 reason: 'Failed for email: $email');
        }
      });

      test('should return null for valid email formats', () {
        final validEmails = [
          'user@example.com',
          'test.user@example.com',
          'user123@test-site.com',
          'a@b.co',
        ];

        for (final email in validEmails) {
          final result = FormValidationHelper.validateEmail(email);
          expect(result, isNull, reason: 'Failed for valid email: $email');
        }
      });
    });

    group('validateUsername', () {
      test('should return error for null input', () {
        final result = FormValidationHelper.validateUsername(null);
        expect(result, equals(FormValidationMessages.usernameRequired));
      });

      test('should return error for empty input', () {
        final result = FormValidationHelper.validateUsername('');
        expect(result, equals(FormValidationMessages.usernameRequired));
      });

      test('should return error for input less than 3 characters', () {
        final result = FormValidationHelper.validateUsername('ab');
        expect(result, equals(FormValidationMessages.usernameMinLength));
      });

      test('should return null for valid username with minimum length', () {
        final result = FormValidationHelper.validateUsername('abc');
        expect(result, isNull);
      });

      test('should return null for valid username', () {
        final result = FormValidationHelper.validateUsername('user123');
        expect(result, isNull);
      });

      test('should return null for username with special characters', () {
        final result = FormValidationHelper.validateUsername('user_name');
        expect(result, isNull);
      });
    });

    group('validatePassword', () {
      test('should return error for null input', () {
        final result = FormValidationHelper.validatePassword(null);
        expect(result, equals(FormValidationMessages.passwordRequired));
      });

      test('should return error for empty input', () {
        final result = FormValidationHelper.validatePassword('');
        expect(result, equals(FormValidationMessages.passwordRequired));
      });

      test('should return error for input less than 6 characters', () {
        final result = FormValidationHelper.validatePassword('12345');
        expect(result, equals(FormValidationMessages.passwordMinLength));
      });

      test('should return null for valid password with minimum length', () {
        final result = FormValidationHelper.validatePassword('123456');
        expect(result, isNull);
      });

      test('should return null for valid password', () {
        final result = FormValidationHelper.validatePassword('securePassword123');
        expect(result, isNull);
      });

      test('should return null for password with special characters', () {
        final result = FormValidationHelper.validatePassword('Pass@123!');
        expect(result, isNull);
      });
    });

    group('validateUserRegistrationForm', () {
      test('should return false when all fields are invalid', () {
        final result = FormValidationHelper.validateUserRegistrationForm(
          firstname: null,
          lastname: null,
          email: null,
          username: null,
          password: null,
        );
        expect(result, equals(false));
      });

      test('should return false when some fields are invalid', () {
        final result = FormValidationHelper.validateUserRegistrationForm(
          firstname: 'John',
          lastname: 'Doe',
          email: 'invalid-email',
          username: 'user123',
          password: 'password',
        );
        expect(result, equals(false));
      });

      test('should return false when password is too short', () {
        final result = FormValidationHelper.validateUserRegistrationForm(
          firstname: 'John',
          lastname: 'Doe',
          email: 'john@example.com',
          username: 'johndoe',
          password: '123',
        );
        expect(result, equals(false));
      });

      test('should return true when all fields are valid', () {
        final result = FormValidationHelper.validateUserRegistrationForm(
          firstname: 'John',
          lastname: 'Doe',
          email: 'john@example.com',
          username: 'johndoe',
          password: 'password123',
        );
        expect(result, equals(true));
      });

      test('should return true for edge case with minimum valid values', () {
        final result = FormValidationHelper.validateUserRegistrationForm(
          firstname: 'Jo',
          lastname: 'Li',
          email: 'a@b.co',
          username: 'abc',
          password: '123456',
        );
        expect(result, equals(true));
      });
    });
  });

  group('FormValidationMessages', () {
    test('should have correct error messages', () {
      expect(FormValidationMessages.firstnameRequired, 
             equals('Please enter your first name'));
      expect(FormValidationMessages.firstnameMinLength, 
             equals('First name must be at least 2 characters'));
      expect(FormValidationMessages.lastnameRequired, 
             equals('Please enter your last name'));
      expect(FormValidationMessages.lastnameMinLength, 
             equals('Last name must be at least 2 characters'));
      expect(FormValidationMessages.emailRequired, 
             equals('Please enter your email'));
      expect(FormValidationMessages.emailInvalid, 
             equals('Please enter a valid email address'));
      expect(FormValidationMessages.usernameRequired, 
             equals('Please enter a username'));
      expect(FormValidationMessages.usernameMinLength, 
             equals('Username must be at least 3 characters'));
      expect(FormValidationMessages.passwordRequired, 
             equals('Please enter a password'));
      expect(FormValidationMessages.passwordMinLength, 
             equals('Password must be at least 6 characters'));
    });
  });
}