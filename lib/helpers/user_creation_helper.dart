import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';

/// UserCreationHelper - Logic for building User objects for API consumption
///
/// This helper encapsulates the business logic for creating User objects
/// that are compatible with the API requirements. Extracted from UI layer.
///
/// **Features:**
/// - API-compatible User object creation
/// - Data sanitization and transformation
/// - Separation of data mapping logic from UI
/// - Easy to test and maintain
class UserCreationHelper {
  /// Create API-compatible User object from form data
  /// 
  /// Takes raw form data and transforms it into a proper User object
  /// that meets API requirements.
  /// 
  /// **API Requirements:**
  /// - Only email, username, password are sent to API
  /// - Name must be provided but with empty strings for API compatibility
  /// - Phone and address are optional (null)
  static User createUserFromFormData({
    required String firstname,
    required String lastname,
    required String email,
    required String username,
    required String password,
  }) {
    return User(
      id: null, // API will assign ID
      email: _sanitizeString(email),
      username: _sanitizeString(username),
      password: _sanitizeString(password),
      name: Name(
        firstname: '', // Empty string since API doesn't use it
        lastname: '', // Empty string since API doesn't use it
      ),
      phone: null, // Not required by API
      address: null, // Not required by API
    );
  }

  /// Create User object that preserves form data for local storage
  /// 
  /// Unlike the API version, this preserves all user input data
  /// for local UserSession storage.
  static User createUserWithFormData({
    required String firstname,
    required String lastname,
    required String email,
    required String username,
    required String password,
  }) {
    return User(
      id: null, // Will be assigned by UserSession
      email: _sanitizeString(email),
      username: _sanitizeString(username),
      password: _sanitizeString(password),
      name: Name(
        firstname: _sanitizeString(firstname),
        lastname: _sanitizeString(lastname),
      ),
      phone: null, // Could be extended later
      address: null, // Could be extended later
    );
  }

  /// Sanitize string input by trimming whitespace
  /// 
  /// Internal helper to ensure clean data
  static String _sanitizeString(String input) {
    return input.trim();
  }

  /// Validate that all required fields have data
  /// 
  /// Returns true if all required fields are non-empty after sanitization
  static bool hasRequiredData({
    required String firstname,
    required String lastname,
    required String email,
    required String username,
    required String password,
  }) {
    return _sanitizeString(firstname).isNotEmpty &&
           _sanitizeString(lastname).isNotEmpty &&
           _sanitizeString(email).isNotEmpty &&
           _sanitizeString(username).isNotEmpty &&
           _sanitizeString(password).isNotEmpty;
  }
}