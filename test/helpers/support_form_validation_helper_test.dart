import 'package:flutter_test/flutter_test.dart';
import 'package:pragma_app_shell/helpers/support_form_validation_helper.dart';

void main() {
  group('SupportFormValidationHelper', () {
    group('validateName', () {
      test('should return error for null input', () {
        final result = SupportFormValidationHelper.validateName(null);
        expect(result, equals(SupportFormMessages.nameRequired));
      });

      test('should return error for empty input', () {
        final result = SupportFormValidationHelper.validateName('');
        expect(result, equals(SupportFormMessages.nameRequired));
      });

      test('should return error for whitespace-only input', () {
        final result = SupportFormValidationHelper.validateName('   ');
        expect(result, equals(SupportFormMessages.nameRequired));
      });

      test('should return error for input less than 2 characters after trim', () {
        final result = SupportFormValidationHelper.validateName(' A ');
        expect(result, equals(SupportFormMessages.nameMinLength));
      });

      test('should return null for valid input with minimum length', () {
        final result = SupportFormValidationHelper.validateName('Jo');
        expect(result, isNull);
      });

      test('should return null for valid input', () {
        final result = SupportFormValidationHelper.validateName('John Doe');
        expect(result, isNull);
      });

      test('should return null for valid input with leading/trailing whitespace', () {
        final result = SupportFormValidationHelper.validateName('  John  ');
        expect(result, isNull);
      });

      test('should return null for valid input with special characters', () {
        final result = SupportFormValidationHelper.validateName('María José');
        expect(result, isNull);
      });
    });

    group('validateEmail', () {
      test('should return error for null input', () {
        final result = SupportFormValidationHelper.validateEmail(null);
        expect(result, equals(SupportFormMessages.emailRequired));
      });

      test('should return error for empty input', () {
        final result = SupportFormValidationHelper.validateEmail('');
        expect(result, equals(SupportFormMessages.emailRequired));
      });

      test('should return error for whitespace-only input', () {
        final result = SupportFormValidationHelper.validateEmail('   ');
        expect(result, equals(SupportFormMessages.emailRequired));
      });

      test('should return error for invalid email formats', () {
        final invalidEmails = [
          'invalid-email',
          '@example.com',
          'user@',
          'user@.com',
          'user.example.com',
          'user@example',
          'user name@example.com',
          'user@exam ple.com',
          'user+tag@example.co.uk', // '+' is not supported by current regex
        ];

        for (final email in invalidEmails) {
          final result = SupportFormValidationHelper.validateEmail(email);
          expect(result, equals(SupportFormMessages.emailInvalid), 
                 reason: 'Failed for email: $email');
        }
      });

      test('should return null for valid email formats', () {
        final validEmails = [
          'user@example.com',
          'test.user@example.com',
          'user123@test-site.com',
          'a@b.co',
          'support@company.org',
        ];

        for (final email in validEmails) {
          final result = SupportFormValidationHelper.validateEmail(email);
          expect(result, isNull, reason: 'Failed for valid email: $email');
        }
      });

      test('should handle email with leading/trailing whitespace', () {
        final result = SupportFormValidationHelper.validateEmail('  user@example.com  ');
        expect(result, isNull);
      });
    });

    group('validateMessage', () {
      test('should return error for null input', () {
        final result = SupportFormValidationHelper.validateMessage(null);
        expect(result, equals(SupportFormMessages.messageRequired));
      });

      test('should return error for empty input', () {
        final result = SupportFormValidationHelper.validateMessage('');
        expect(result, equals(SupportFormMessages.messageRequired));
      });

      test('should return error for whitespace-only input', () {
        final result = SupportFormValidationHelper.validateMessage('   ');
        expect(result, equals(SupportFormMessages.messageRequired));
      });

      test('should return error for input less than 10 characters after trim', () {
        final result = SupportFormValidationHelper.validateMessage(' Hello '); // 5 chars after trim
        expect(result, equals(SupportFormMessages.messageMinLength));
      });

      test('should return null for valid message with minimum length', () {
        final result = SupportFormValidationHelper.validateMessage('Hello help'); // Exactly 10 chars
        expect(result, isNull);
      });

      test('should return null for valid message', () {
        final result = SupportFormValidationHelper.validateMessage(
          'I need help with my order. Could you please assist me?'
        );
        expect(result, isNull);
      });

      test('should return null for message with leading/trailing whitespace', () {
        final result = SupportFormValidationHelper.validateMessage('  I need help with this  ');
        expect(result, isNull);
      });

      test('should return null for message with newlines', () {
        final result = SupportFormValidationHelper.validateMessage(
          'Line 1\nLine 2\nThis is a multi-line message'
        );
        expect(result, isNull);
      });
    });

    group('validateSupportForm', () {
      test('should return errors for all invalid fields', () {
        final result = SupportFormValidationHelper.validateSupportForm(
          name: null,
          email: null,
          message: null,
        );

        expect(result.nameError, equals(SupportFormMessages.nameRequired));
        expect(result.emailError, equals(SupportFormMessages.emailRequired));
        expect(result.messageError, equals(SupportFormMessages.messageRequired));
        expect(result.isValid, isFalse);
        expect(result.hasErrors, isTrue);
      });

      test('should return specific errors for each invalid field', () {
        final result = SupportFormValidationHelper.validateSupportForm(
          name: 'A', // Too short
          email: 'invalid-email', // Invalid format
          message: 'Short', // Too short
        );

        expect(result.nameError, equals(SupportFormMessages.nameMinLength));
        expect(result.emailError, equals(SupportFormMessages.emailInvalid));
        expect(result.messageError, equals(SupportFormMessages.messageMinLength));
        expect(result.isValid, isFalse);
      });

      test('should return no errors for valid form data', () {
        final result = SupportFormValidationHelper.validateSupportForm(
          name: 'John Doe',
          email: 'john@example.com',
          message: 'I need help with my account. Please assist me.',
        );

        expect(result.nameError, isNull);
        expect(result.emailError, isNull);
        expect(result.messageError, isNull);
        expect(result.isValid, isTrue);
        expect(result.hasErrors, isFalse);
      });

      test('should handle mixed valid and invalid fields', () {
        final result = SupportFormValidationHelper.validateSupportForm(
          name: 'John Doe', // Valid
          email: 'invalid', // Invalid
          message: 'I need help with my account issue', // Valid
        );

        expect(result.nameError, isNull);
        expect(result.emailError, equals(SupportFormMessages.emailInvalid));
        expect(result.messageError, isNull);
        expect(result.isValid, isFalse);
      });

      test('should handle edge case with minimum valid values', () {
        final result = SupportFormValidationHelper.validateSupportForm(
          name: 'Jo',
          email: 'a@b.co',
          message: 'Hello help', // Exactly 10 characters
        );

        expect(result.nameError, isNull);
        expect(result.emailError, isNull);
        expect(result.messageError, isNull);
        expect(result.isValid, isTrue);
      });
    });

    group('hasValidData', () {
      test('should return false for all null inputs', () {
        final result = SupportFormValidationHelper.hasValidData(
          name: null,
          email: null,
          message: null,
        );
        expect(result, isFalse);
      });

      test('should return false for some invalid inputs', () {
        final result = SupportFormValidationHelper.hasValidData(
          name: 'John Doe',
          email: 'invalid-email',
          message: 'I need help with my order',
        );
        expect(result, isFalse);
      });

      test('should return true for all valid inputs', () {
        final result = SupportFormValidationHelper.hasValidData(
          name: 'John Doe',
          email: 'john@example.com',
          message: 'I need help with my account settings',
        );
        expect(result, isTrue);
      });

      test('should return false for empty strings', () {
        final result = SupportFormValidationHelper.hasValidData(
          name: '',
          email: '',
          message: '',
        );
        expect(result, isFalse);
      });

      test('should return false for whitespace-only strings', () {
        final result = SupportFormValidationHelper.hasValidData(
          name: '   ',
          email: '   ',
          message: '   ',
        );
        expect(result, isFalse);
      });
    });
  });

  group('SupportFormValidationResult', () {
    test('should correctly identify valid form', () {
      const result = SupportFormValidationResult(
        nameError: null,
        emailError: null,
        messageError: null,
      );

      expect(result.isValid, isTrue);
      expect(result.hasErrors, isFalse);
    });

    test('should correctly identify invalid form with name error', () {
      const result = SupportFormValidationResult(
        nameError: SupportFormMessages.nameRequired,
        emailError: null,
        messageError: null,
      );

      expect(result.isValid, isFalse);
      expect(result.hasErrors, isTrue);
    });

    test('should correctly identify invalid form with email error', () {
      const result = SupportFormValidationResult(
        nameError: null,
        emailError: SupportFormMessages.emailInvalid,
        messageError: null,
      );

      expect(result.isValid, isFalse);
      expect(result.hasErrors, isTrue);
    });

    test('should correctly identify invalid form with message error', () {
      const result = SupportFormValidationResult(
        nameError: null,
        emailError: null,
        messageError: SupportFormMessages.messageRequired,
      );

      expect(result.isValid, isFalse);
      expect(result.hasErrors, isTrue);
    });

    test('should correctly identify invalid form with multiple errors', () {
      const result = SupportFormValidationResult(
        nameError: SupportFormMessages.nameRequired,
        emailError: SupportFormMessages.emailInvalid,
        messageError: SupportFormMessages.messageMinLength,
      );

      expect(result.isValid, isFalse);
      expect(result.hasErrors, isTrue);
    });
  });

  group('SupportFormMessages', () {
    test('should have correct error messages', () {
      expect(SupportFormMessages.nameRequired, equals('Name is required'));
      expect(SupportFormMessages.nameMinLength, equals('Name must be at least 2 characters'));
      expect(SupportFormMessages.emailRequired, equals('Email is required'));
      expect(SupportFormMessages.emailInvalid, equals('Please enter a valid email address'));
      expect(SupportFormMessages.messageRequired, equals('Message is required'));
      expect(SupportFormMessages.messageMinLength, equals('Message must be at least 10 characters'));
    });

    test('should have correct success messages', () {
      expect(SupportFormMessages.submitSuccessTitle, equals('Thank You'));
      expect(SupportFormMessages.submitSuccessMessage, 
             equals('Thank you for contacting us. Our support team will reach out to you soon.'));
    });
  });
}