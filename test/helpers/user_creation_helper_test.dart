import 'package:flutter_test/flutter_test.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';
import 'package:pragma_app_shell/helpers/user_creation_helper.dart';

void main() {
  group('UserCreationHelper', () {
    // Test data
    const testFirstname = 'John';
    const testLastname = 'Doe';
    const testEmail = 'john.doe@example.com';
    const testUsername = 'johndoe123';
    const testPassword = 'securePassword';

    group('createUserFromFormData', () {
      test('should create API-compatible User object', () {
        final user = UserCreationHelper.createUserFromFormData(
          firstname: testFirstname,
          lastname: testLastname,
          email: testEmail,
          username: testUsername,
          password: testPassword,
        );

        expect(user.id, isNull);
        expect(user.email, equals(testEmail));
        expect(user.username, equals(testUsername));
        expect(user.password, equals(testPassword));
        expect(user.name?.firstname, equals('')); // API requirement: empty string
        expect(user.name?.lastname, equals('')); // API requirement: empty string
        expect(user.phone, isNull);
        expect(user.address, isNull);
      });

      test('should sanitize input strings by trimming whitespace', () {
        final user = UserCreationHelper.createUserFromFormData(
          firstname: '  $testFirstname  ',
          lastname: '  $testLastname  ',
          email: '  $testEmail  ',
          username: '  $testUsername  ',
          password: '  $testPassword  ',
        );

        expect(user.email, equals(testEmail));
        expect(user.username, equals(testUsername));
        expect(user.password, equals(testPassword));
        expect(user.name?.firstname, equals(''));
        expect(user.name?.lastname, equals(''));
      });

      test('should handle empty strings after trimming', () {
        final user = UserCreationHelper.createUserFromFormData(
          firstname: '   ',
          lastname: '   ',
          email: '   ',
          username: '   ',
          password: '   ',
        );

        expect(user.email, equals(''));
        expect(user.username, equals(''));
        expect(user.password, equals(''));
        expect(user.name?.firstname, equals(''));
        expect(user.name?.lastname, equals(''));
      });

      test('should create user with special characters in data', () {
        final user = UserCreationHelper.createUserFromFormData(
          firstname: 'José',
          lastname: 'García-López',
          email: 'jose.garcia+test@example.com',
          username: 'jose_garcia123',
          password: 'Pass@word!123',
        );

        expect(user.email, equals('jose.garcia+test@example.com'));
        expect(user.username, equals('jose_garcia123'));
        expect(user.password, equals('Pass@word!123'));
      });
    });

    group('createUserWithFormData', () {
      test('should preserve form data for local storage', () {
        final user = UserCreationHelper.createUserWithFormData(
          firstname: testFirstname,
          lastname: testLastname,
          email: testEmail,
          username: testUsername,
          password: testPassword,
        );

        expect(user.id, isNull);
        expect(user.email, equals(testEmail));
        expect(user.username, equals(testUsername));
        expect(user.password, equals(testPassword));
        expect(user.name?.firstname, equals(testFirstname)); // Preserved for local storage
        expect(user.name?.lastname, equals(testLastname)); // Preserved for local storage
        expect(user.phone, isNull);
        expect(user.address, isNull);
      });

      test('should sanitize form data', () {
        final user = UserCreationHelper.createUserWithFormData(
          firstname: '  $testFirstname  ',
          lastname: '  $testLastname  ',
          email: '  $testEmail  ',
          username: '  $testUsername  ',
          password: '  $testPassword  ',
        );

        expect(user.email, equals(testEmail));
        expect(user.username, equals(testUsername));
        expect(user.password, equals(testPassword));
        expect(user.name?.firstname, equals(testFirstname));
        expect(user.name?.lastname, equals(testLastname));
      });

      test('should handle unicode characters properly', () {
        final user = UserCreationHelper.createUserWithFormData(
          firstname: 'María',
          lastname: 'Jiménez',
          email: 'maria.jimenez@example.com',
          username: 'maria_jimenez',
          password: 'contraseña123',
        );

        expect(user.name?.firstname, equals('María'));
        expect(user.name?.lastname, equals('Jiménez'));
        expect(user.email, equals('maria.jimenez@example.com'));
        expect(user.username, equals('maria_jimenez'));
        expect(user.password, equals('contraseña123'));
      });
    });

    group('hasRequiredData', () {
      test('should return true for complete valid data', () {
        final result = UserCreationHelper.hasRequiredData(
          firstname: testFirstname,
          lastname: testLastname,
          email: testEmail,
          username: testUsername,
          password: testPassword,
        );

        expect(result, isTrue);
      });

      test('should return false for null firstname', () {
        final result = UserCreationHelper.hasRequiredData(
          firstname: '',  // Use empty string instead of null
          lastname: testLastname,
          email: testEmail,
          username: testUsername,
          password: testPassword,
        );

        expect(result, isFalse);
      });

      test('should return false for empty firstname after trimming', () {
        final result = UserCreationHelper.hasRequiredData(
          firstname: '   ',
          lastname: testLastname,
          email: testEmail,
          username: testUsername,
          password: testPassword,
        );

        expect(result, isFalse);
      });

      test('should return false for null lastname', () {
        final result = UserCreationHelper.hasRequiredData(
          firstname: testFirstname,
          lastname: '',  // Use empty string instead of null
          email: testEmail,
          username: testUsername,
          password: testPassword,
        );

        expect(result, isFalse);
      });

      test('should return false for empty lastname after trimming', () {
        final result = UserCreationHelper.hasRequiredData(
          firstname: testFirstname,
          lastname: '   ',
          email: testEmail,
          username: testUsername,
          password: testPassword,
        );

        expect(result, isFalse);
      });

      test('should return false for null email', () {
        final result = UserCreationHelper.hasRequiredData(
          firstname: testFirstname,
          lastname: testLastname,
          email: '',  // Use empty string instead of null
          username: testUsername,
          password: testPassword,
        );

        expect(result, isFalse);
      });

      test('should return false for empty email after trimming', () {
        final result = UserCreationHelper.hasRequiredData(
          firstname: testFirstname,
          lastname: testLastname,
          email: '   ',
          username: testUsername,
          password: testPassword,
        );

        expect(result, isFalse);
      });

      test('should return false for null username', () {
        final result = UserCreationHelper.hasRequiredData(
          firstname: testFirstname,
          lastname: testLastname,
          email: testEmail,
          username: '',  // Use empty string instead of null
          password: testPassword,
        );

        expect(result, isFalse);
      });

      test('should return false for empty username after trimming', () {
        final result = UserCreationHelper.hasRequiredData(
          firstname: testFirstname,
          lastname: testLastname,
          email: testEmail,
          username: '   ',
          password: testPassword,
        );

        expect(result, isFalse);
      });

      test('should return false for null password', () {
        final result = UserCreationHelper.hasRequiredData(
          firstname: testFirstname,
          lastname: testLastname,
          email: testEmail,
          username: testUsername,
          password: '',  // Use empty string instead of null
        );

        expect(result, isFalse);
      });

      test('should return false for empty password after trimming', () {
        final result = UserCreationHelper.hasRequiredData(
          firstname: testFirstname,
          lastname: testLastname,
          email: testEmail,
          username: testUsername,
          password: '   ',
        );

        expect(result, isFalse);
      });

      test('should return false when all fields are null', () {
        final result = UserCreationHelper.hasRequiredData(
          firstname: '',
          lastname: '',
          email: '',
          username: '',
          password: '',
        );

        expect(result, isFalse);
      });

      test('should return false when all fields are empty', () {
        final result = UserCreationHelper.hasRequiredData(
          firstname: '',
          lastname: '',
          email: '',
          username: '',
          password: '',
        );

        expect(result, isFalse);
      });

      test('should return true for data with leading/trailing whitespace', () {
        final result = UserCreationHelper.hasRequiredData(
          firstname: '  $testFirstname  ',
          lastname: '  $testLastname  ',
          email: '  $testEmail  ',
          username: '  $testUsername  ',
          password: '  $testPassword  ',
        );

        expect(result, isTrue);
      });

      test('should return true for minimum valid data', () {
        final result = UserCreationHelper.hasRequiredData(
          firstname: 'A',
          lastname: 'B',
          email: 'a@b.c',
          username: 'abc',
          password: '123456',
        );

        expect(result, isTrue);
      });
    });

    group('_sanitizeString (tested through public methods)', () {
      test('should trim whitespace from beginning and end', () {
        final user = UserCreationHelper.createUserWithFormData(
          firstname: '  John  ',
          lastname: '  Doe  ',
          email: '  john@example.com  ',
          username: '  johndoe  ',
          password: '  password  ',
        );

        expect(user.name?.firstname, equals('John'));
        expect(user.name?.lastname, equals('Doe'));
        expect(user.email, equals('john@example.com'));
        expect(user.username, equals('johndoe'));
        expect(user.password, equals('password'));
      });

      test('should handle strings with only whitespace', () {
        final user = UserCreationHelper.createUserWithFormData(
          firstname: '   ',
          lastname: '\t\t',
          email: '\n\n',
          username: '  ',
          password: '\r\n',
        );

        expect(user.name?.firstname, equals(''));
        expect(user.name?.lastname, equals(''));
        expect(user.email, equals(''));
        expect(user.username, equals(''));
        expect(user.password, equals(''));
      });

      test('should preserve internal whitespace', () {
        final user = UserCreationHelper.createUserWithFormData(
          firstname: '  John Michael  ',
          lastname: '  Van Der Berg  ',
          email: '  john michael@example.com  ',
          username: '  john_michael  ',
          password: '  my password  ',
        );

        expect(user.name?.firstname, equals('John Michael'));
        expect(user.name?.lastname, equals('Van Der Berg'));
        expect(user.email, equals('john michael@example.com'));
        expect(user.username, equals('john_michael'));
        expect(user.password, equals('my password'));
      });
    });
  });
}