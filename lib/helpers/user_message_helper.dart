import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';

/// UserMessageHelper - Centralized message formatting for user operations
///
/// This helper provides formatted messages for user creation success/error scenarios.
/// Extracted from UI layer to maintain separation of concerns.
///
/// **Features:**
/// - Formatted success messages
/// - Error message handling  
/// - Consistent message styling
/// - Easy to localize in the future
class UserMessageHelper {
  /// Format success snackbar message
  static String getSuccessSnackbarMessage() {
    return 'User created! You can now log in.';
  }

  /// Format error snackbar message
  static String getErrorSnackbarMessage(String? error) {
    return error ?? 'Failed to create user. Please try again.';
  }

  /// Format success dialog title
  static String getSuccessDialogTitle() {
    return 'User Created Successfully!';
  }

  /// Format success dialog content with user details
  static String getSuccessDialogContent(User user) {
    final buffer = StringBuffer();
    
    // Main success message
    buffer.writeln('Your account has been created successfully!');
    buffer.writeln();
    buffer.writeln('You can now sign in with your new credentials.');
    buffer.writeln();
    
    // User details section
    buffer.writeln('User Details:');
    buffer.writeln('ID: ${_formatUserId(user.id)}');
    buffer.writeln('Username: ${_formatField(user.username)}');
    buffer.writeln('Email: ${_formatField(user.email)}');
    
    return buffer.toString();
  }

  /// Format success dialog action button text
  static String getSuccessDialogActionText() {
    return 'Go to Login';
  }

  /// Format user ID for display
  static String _formatUserId(int? id) {
    return id?.toString() ?? 'Auto-generated';
  }

  /// Format optional field for display
  static String _formatField(String? value) {
    return value ?? 'N/A';
  }
}

/// UserSessionMessages - Messages related to UserSession operations
///
/// Contains messages for specific UserSession scenarios
class UserSessionMessages {
  static const String userAlreadyExists = 'User might already exist';
  static const String sessionWarningPrefix = 'UserSession warning:';
}