/// FormValidationHelper - Centralized validation logic for user forms
///
/// This helper provides reusable validation methods for user registration forms.
/// Extracted from UI layer to maintain separation of concerns.
///
/// **Features:**
/// - Field-specific validation methods
/// - Consistent validation rules
/// - Reusable across multiple forms
/// - Easy to test in isolation
class FormValidationHelper {
  /// Validate first name field
  /// 
  /// Returns null if valid, error message if invalid
  static String? validateFirstname(String? value) {
    if (value == null || value.isEmpty) {
      return FormValidationMessages.firstnameRequired;
    }
    if (value.length < 2) {
      return FormValidationMessages.firstnameMinLength;
    }
    return null;
  }

  /// Validate last name field
  /// 
  /// Returns null if valid, error message if invalid
  static String? validateLastname(String? value) {
    if (value == null || value.isEmpty) {
      return FormValidationMessages.lastnameRequired;
    }
    if (value.length < 2) {
      return FormValidationMessages.lastnameMinLength;
    }
    return null;
  }

  /// Validate email field with regex pattern
  /// 
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return FormValidationMessages.emailRequired;
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return FormValidationMessages.emailInvalid;
    }
    return null;
  }

  /// Validate username field
  /// 
  /// Returns null if valid, error message if invalid
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return FormValidationMessages.usernameRequired;
    }
    if (value.length < 3) {
      return FormValidationMessages.usernameMinLength;
    }
    return null;
  }

  /// Validate password field
  /// 
  /// Returns null if valid, error message if invalid
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return FormValidationMessages.passwordRequired;
    }
    if (value.length < 6) {
      return FormValidationMessages.passwordMinLength;
    }
    return null;
  }

  /// Validate complete user registration form
  /// 
  /// Returns true if all fields are valid
  static bool validateUserRegistrationForm({
    required String? firstname,
    required String? lastname,
    required String? email,
    required String? username,
    required String? password,
  }) {
    return validateFirstname(firstname) == null &&
           validateLastname(lastname) == null &&
           validateEmail(email) == null &&
           validateUsername(username) == null &&
           validatePassword(password) == null;
  }
}

/// FormValidationMessages - Centralized validation messages
///
/// Contains all form validation error messages in one place
/// for consistency and easy maintenance.
class FormValidationMessages {
  // First name validation messages
  static const String firstnameRequired = 'Please enter your first name';
  static const String firstnameMinLength = 'First name must be at least 2 characters';

  // Last name validation messages
  static const String lastnameRequired = 'Please enter your last name';
  static const String lastnameMinLength = 'Last name must be at least 2 characters';

  // Email validation messages
  static const String emailRequired = 'Please enter your email';
  static const String emailInvalid = 'Please enter a valid email address';

  // Username validation messages
  static const String usernameRequired = 'Please enter a username';
  static const String usernameMinLength = 'Username must be at least 3 characters';

  // Password validation messages
  static const String passwordRequired = 'Please enter a password';
  static const String passwordMinLength = 'Password must be at least 6 characters';
}