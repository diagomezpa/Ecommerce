/// SupportFormValidationHelper - Validation logic for support forms
///
/// This helper centralizes validation logic for support contact forms.
/// Extracted from UI layer to maintain separation of concerns.
///
/// **Features:**
/// - Form field validation methods
/// - Complete form validation
/// - Centralized validation rules
/// - Reusable across multiple forms
/// - Easy to test and maintain
class SupportFormValidationHelper {
  /// Validate name field
  /// 
  /// Returns null if valid, error message if invalid
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return SupportFormMessages.nameRequired;
    }
    if (value.trim().length < 2) {
      return SupportFormMessages.nameMinLength;
    }
    return null;
  }

  /// Validate email field
  /// 
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return SupportFormMessages.emailRequired;
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return SupportFormMessages.emailInvalid;
    }
    return null;
  }

  /// Validate message field
  /// 
  /// Returns null if valid, error message if invalid
  static String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return SupportFormMessages.messageRequired;
    }
    if (value.trim().length < 10) {
      return SupportFormMessages.messageMinLength;
    }
    return null;
  }

  /// Validate complete support form
  /// 
  /// Returns validation result with errors for each field
  static SupportFormValidationResult validateSupportForm({
    required String? name,
    required String? email,
    required String? message,
  }) {
    return SupportFormValidationResult(
      nameError: validateName(name),
      emailError: validateEmail(email),
      messageError: validateMessage(message),
    );
  }

  /// Check if form data has required content
  /// 
  /// Returns true if all required fields have valid data
  static bool hasValidData({
    required String? name,
    required String? email,
    required String? message,
  }) {
    return validateName(name) == null &&
           validateEmail(email) == null &&
           validateMessage(message) == null;
  }
}

/// SupportFormValidationResult - Result of form validation
/// 
/// Encapsulates validation errors for each field
class SupportFormValidationResult {
  final String? nameError;
  final String? emailError;
  final String? messageError;

  const SupportFormValidationResult({
    this.nameError,
    this.emailError,
    this.messageError,
  });

  /// Check if form is valid (no errors)
  bool get isValid => nameError == null && emailError == null && messageError == null;

  /// Check if form has any errors
  bool get hasErrors => !isValid;
}

/// SupportFormMessages - Centralized validation messages
///
/// Contains all support form validation error messages
class SupportFormMessages {
  // Name validation messages
  static const String nameRequired = 'Name is required';
  static const String nameMinLength = 'Name must be at least 2 characters';

  // Email validation messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email address';

  // Message validation messages  
  static const String messageRequired = 'Message is required';
  static const String messageMinLength = 'Message must be at least 10 characters';

  // Success messages
  static const String submitSuccessTitle = 'Thank You';
  static const String submitSuccessMessage = 
      'Thank you for contacting us. Our support team will reach out to you soon.';
}