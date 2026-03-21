import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';

/// UserSession - In-memory user persistence and session management
///
/// This service provides a simple in-memory storage solution for users
/// since the fake API doesn't persist created users.
///
/// **Features:**
/// - In-memory user storage using singleton pattern
/// - Add new users to memory storage
/// - Find users by username and password for authentication
/// - Current user session management
/// - Clean and testable architecture
///
/// **Usage:**
/// ```dart
/// final userSession = UserSession();
/// 
/// // Add a created user to memory
/// userSession.addUser(newUser);
/// 
/// // Find user for login
/// final user = userSession.findUser('username', 'password');
/// 
/// // Set current logged user
/// userSession.setCurrentUser(user);
/// ```
///
/// **Note:** This is a temporary solution for development/testing.
/// In production, replace with proper database persistence.
class UserSession {
  // Singleton pattern implementation
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  // In-memory storage
  final List<User> _users = [];
  User? _currentUser;
  int _nextUserId = 1;

  /// Add a new user to in-memory storage
  /// 
  /// Assigns a unique ID if not provided and stores the user.
  /// Returns the user with assigned ID.
  User addUser(User user) {
    // Assign ID if not provided
    final userWithId = User(
      id: user.id ?? _nextUserId++,
      email: user.email,
      username: user.username,
      password: user.password,
      name: user.name,
      phone: user.phone,
      address: user.address,
    );

    // Check if username already exists
    if (userExists(userWithId.username ?? '')) {
      throw UserSessionException('Username already exists: ${userWithId.username}');
    }

    // Check if email already exists
    if (emailExists(userWithId.email ?? '')) {
      throw UserSessionException('Email already exists: ${userWithId.email}');
    }

    _users.add(userWithId);
    return userWithId;
  }

  /// Find user by username and password for authentication
  /// 
  /// Returns the user if found and credentials match, null otherwise.
  User? findUser(String username, String password) {
    final matches = _users.where(
      (user) => 
        user.username == username && 
        user.password == password,
    );
    return matches.isNotEmpty ? matches.first : null;
  }

  /// Find user by username only
  /// 
  /// Useful for checking if username exists during registration.
  User? findUserByUsername(String username) {
    final matches = _users.where((user) => user.username == username);
    return matches.isNotEmpty ? matches.first : null;
  }

  /// Find user by email
  /// 
  /// Useful for email-based authentication or validation.
  User? findUserByEmail(String email) {
    final matches = _users.where((user) => user.email == email);
    return matches.isNotEmpty ? matches.first : null;
  }

  /// Set currently logged-in user
  /// 
  /// Manages the current session state.
  void setCurrentUser(User user) {
    _currentUser = user;
  }

  /// Get currently logged-in user
  /// 
  /// Returns null if no user is logged in.
  User? getCurrentUser() {
    return _currentUser;
  }

  /// Check if any user is currently logged in
  /// 
  /// Returns true if there's an active session.
  bool isLoggedIn() {
    return _currentUser != null;
  }

  /// Logout current user
  /// 
  /// Clears the current session.
  void logout() {
    _currentUser = null;
  }

  /// Check if username already exists
  /// 
  /// Returns true if username is taken.
  bool userExists(String username) {
    return findUserByUsername(username) != null;
  }

  /// Check if email already exists
  /// 
  /// Returns true if email is already registered.
  bool emailExists(String email) {
    return findUserByEmail(email) != null;
  }

  /// Get all stored users
  /// 
  /// Primarily for debugging and testing purposes.
  List<User> getAllUsers() {
    return List.unmodifiable(_users);
  }

  /// Get total number of users
  /// 
  /// Returns count of registered users.
  int getUserCount() {
    return _users.length;
  }

  /// Clear all users and session (for testing)
  /// 
  /// ⚠️ Use only in development/testing environments.
  void clearAll() {
    _users.clear();
    _currentUser = null;
    _nextUserId = 1;
  }

  /// Update user information
  /// 
  /// Updates an existing user's data and returns updated user.
  User? updateUser(int userId, User updatedUser) {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index == -1) return null;

    final userWithId = User(
      id: userId,
      email: updatedUser.email,
      username: updatedUser.username,
      password: updatedUser.password,
      name: updatedUser.name,
      phone: updatedUser.phone,
      address: updatedUser.address,
    );

    _users[index] = userWithId;

    // Update current user if it's the same user
    if (_currentUser?.id == userId) {
      _currentUser = userWithId;
    }

    return userWithId;
  }

  /// Remove user from storage
  /// 
  /// Returns true if user was removed successfully.
  bool removeUser(int userId) {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index == -1) return false;

    _users.removeAt(index);

    // Logout if current user was removed
    if (_currentUser?.id == userId) {
      logout();
    }

    return true;
  }

  /// Search users by name (firstname or lastname)
  /// 
  /// Returns list of users matching the search term.
  List<User> searchUsersByName(String searchTerm) {
    if (searchTerm.isEmpty) return [];

    return _users.where((user) {
      final name = user.name;
      
      final firstname = name.firstname.toLowerCase();
      final lastname = name.lastname.toLowerCase();
      final search = searchTerm.toLowerCase();
      
      return firstname.contains(search) || lastname.contains(search);
    }).toList();
  }

  /// Get user statistics for admin/debugging
  /// 
  /// Returns basic statistics about stored users.
  Map<String, dynamic> getStatistics() {
    return {
      'totalUsers': _users.length,
      'currentUser': _currentUser?.username ?? 'None',
      'hasCurrentSession': isLoggedIn(),
      'usersWithEmail': _users.where((u) => u.email != null).length,
      'usersWithPhone': _users.where((u) => u.phone != null).length,
      'usersWithAddress': _users.where((u) => u.address != null).length,
    };
  }
}

/// Custom exception for UserSession operations
/// 
/// Thrown when user session operations fail due to business logic violations.
class UserSessionException implements Exception {
  final String message;
  
  const UserSessionException(this.message);
  
  @override
  String toString() => 'UserSessionException: $message';
}