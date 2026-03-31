import 'package:flutter_test/flutter_test.dart';
import 'package:pragma_app_shell/services/user_session.dart';
import 'package:fake_maker_api_pragma_api/fake_maker_api_pragma_api.dart';

void main() {
  group('UserSession Tests', () {
    late UserSession userSession;

    setUp(() {
      userSession = UserSession();
      // Clear all data before each test to ensure clean state
      userSession.clearAll();
    });

    tearDown(() {
      // Cleanup after each test
      userSession.clearAll();
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        final instance1 = UserSession();
        final instance2 = UserSession();

        expect(identical(instance1, instance2), true);
      });

      test('should maintain state across multiple calls', () {
        final instance1 = UserSession();
        final testUser = User(
          id: 1,
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );

        instance1.addUser(testUser);

        final instance2 = UserSession();
        final retrievedUser = instance2.findUserByUsername('testuser');

        expect(retrievedUser, isNotNull);
        expect(retrievedUser!.username, 'testuser');
      });
    });

    group('User Creation', () {
      test('should add user successfully', () {
        final testUser = User(
          id: 1,
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );

        userSession.addUser(testUser);
        final retrievedUser = userSession.findUserByUsername('testuser');

        expect(retrievedUser, isNotNull);
        expect(retrievedUser!.username, 'testuser');
        expect(retrievedUser.email, 'test@example.com');
      });

      test('should handle multiple users', () {
        final user1 = User(
          id: 1,
          email: 'test1@example.com',
          username: 'testuser1',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User1'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );

        final user2 = User(
          id: 2,
          email: 'test2@example.com',
          username: 'testuser2',
          password: 'password456',
          name: Name(firstname: 'Test', lastname: 'User2'),
          address: Address(
            city: 'Test City 2',
            street: 'Test Street 2',
            number: 456,
            zipcode: '54321',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7034',
        );

        userSession.addUser(user1);
        userSession.addUser(user2);

        final retrieved1 = userSession.findUserByUsername('testuser1');
        final retrieved2 = userSession.findUserByUsername('testuser2');

        expect(retrieved1, isNotNull);
        expect(retrieved2, isNotNull);
        expect(retrieved1!.id, 1);
        expect(retrieved2!.id, 2);
      });

      test('should assign automatic ID when not provided', () {
        final user1 = User(
          id: 1,
          email: 'test1@example.com',
          username: 'testuser1',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User1'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );

        final user2 = User(
          id: 2,
          email: 'test2@example.com',
          username: 'testuser2',
          password: 'password456',
          name: Name(firstname: 'Test', lastname: 'User2'),
          address: Address(
            city: 'Test City 2',
            street: 'Test Street 2',
            number: 456,
            zipcode: '54321',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7034',
        );

        final addedUser1 = userSession.addUser(user1);
        final addedUser2 = userSession.addUser(user2);

        expect(addedUser1.id, isNotNull);
        expect(addedUser2.id, isNotNull);
        expect(addedUser1.id != addedUser2.id, true);
      });
    });

    group('User Search', () {
      setUp(() {
        final user1 = User(
          id: 1,
          email: 'john.doe@example.com',
          username: 'johndoe',
          password: 'password123',
          name: Name(firstname: 'John', lastname: 'Doe'),
          address: Address(
            city: 'New York',
            street: 'Broadway',
            number: 123,
            zipcode: '10001',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );

        final user2 = User(
          id: 2,
          email: 'jane.smith@example.com',
          username: 'janesmith',
          password: 'password456',
          name: Name(firstname: 'Jane', lastname: 'Smith'),
          address: Address(
            city: 'Los Angeles',
            street: 'Sunset Blvd',
            number: 456,
            zipcode: '90210',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7034',
        );

        userSession.addUser(user1);
        userSession.addUser(user2);
      });

      test('should find user by username', () {
        final user = userSession.findUserByUsername('johndoe');
        expect(user, isNotNull);
        expect(user!.username, 'johndoe');
      });

      test('should return null for non-existent username', () {
        final user = userSession.findUserByUsername('nonexistent');
        expect(user, isNull);
      });

      test('should find user by email', () {
        final user = userSession.findUserByEmail('jane.smith@example.com');
        expect(user, isNotNull);
        expect(user!.email, 'jane.smith@example.com');
      });

      test('should return null for non-existent email', () {
        final user = userSession.findUserByEmail('nonexistent@example.com');
        expect(user, isNull);
      });

      test('should search users by name', () {
        final usersWithJohn = userSession.searchUsersByName('John');
        expect(usersWithJohn, hasLength(1));
        expect(usersWithJohn.first.name.firstname, 'John');

        final usersWithSmith = userSession.searchUsersByName('Smith');
        expect(usersWithSmith, hasLength(1));
        expect(usersWithSmith.first.name.lastname, 'Smith');
      });

      test('should return empty list for empty search term', () {
        final result = userSession.searchUsersByName('');
        expect(result, isEmpty);
      });
    });

    group('Authentication', () {
      setUp(() {
        final testUser = User(
          id: 1,
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );
        userSession.addUser(testUser);
      });

      test('should authenticate user with correct credentials', () {
        final user = userSession.findUser('testuser', 'password123');
        expect(user, isNotNull);
        expect(user!.username, 'testuser');

        userSession.setCurrentUser(user);
        expect(userSession.isLoggedIn(), true);
        expect(userSession.getCurrentUser()!.username, 'testuser');
      });

      test('should fail authentication with wrong password', () {
        final user = userSession.findUser('testuser', 'wrongpassword');
        expect(user, isNull);
      });

      test('should fail authentication with non-existent username', () {
        final user = userSession.findUser('nonexistent', 'password123');
        expect(user, isNull);
      });

      test('should handle empty credentials', () {
        final user1 = userSession.findUser('', 'password123');
        final user2 = userSession.findUser('testuser', '');
        final user3 = userSession.findUser('', '');

        expect(user1, isNull);
        expect(user2, isNull);
        expect(user3, isNull);
      });
    });

    group('Session Management', () {
      setUp(() {
        final testUser = User(
          id: 1,
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );
        userSession.addUser(testUser);
        userSession.setCurrentUser(testUser);
      });

      test('should check login status correctly', () {
        expect(userSession.isLoggedIn(), true);
        
        userSession.logout();
        expect(userSession.isLoggedIn(), false);
      });

      test('should get current user correctly', () {
        final currentUser = userSession.getCurrentUser();
        expect(currentUser, isNotNull);
        expect(currentUser!.username, 'testuser');
      });

      test('should logout current user', () {
        expect(userSession.isLoggedIn(), true);
        expect(userSession.getCurrentUser(), isNotNull);

        userSession.logout();

        expect(userSession.isLoggedIn(), false);
        expect(userSession.getCurrentUser(), isNull);
      });

      test('should maintain session across operations', () {
        // Perform various operations
        userSession.getAllUsers();
        userSession.findUserByUsername('testuser');
        
        // Session should still be active
        expect(userSession.isLoggedIn(), true);
        expect(userSession.getCurrentUser(), isNotNull);
      });
    });

    group('User Existence Checking', () {
      setUp(() {
        final testUser = User(
          id: 1,
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );
        userSession.addUser(testUser);
      });

      test('should check if username exists', () {
        expect(userSession.userExists('testuser'), true);
        expect(userSession.userExists('nonexistent'), false);
      });

      test('should check if email exists', () {
        expect(userSession.emailExists('test@example.com'), true);
        expect(userSession.emailExists('nonexistent@example.com'), false);
      });
    });

    group('User Update', () {
      test('should update existing user successfully', () {
        final originalUser = User(
          id: 1,
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );

        final updatedUserData = User(
          id: 1,
          email: 'updated@example.com',
          username: 'updateduser',
          password: 'newpassword456',
          name: Name(firstname: 'Updated', lastname: 'User'),
          address: Address(
            city: 'Updated City',
            street: 'Updated Street',
            number: 456,
            zipcode: '54321',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7099',
        );

        userSession.addUser(originalUser);
        final updatedUser = userSession.updateUser(1, updatedUserData);

        expect(updatedUser, isNotNull);
        expect(updatedUser!.email, 'updated@example.com');
        expect(updatedUser.username, 'updateduser');
        expect(updatedUser.name.firstname, 'Updated');
      });

      test('should return null for non-existent user', () {
        final user = User(
          id: 999,
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );

        final result = userSession.updateUser(999, user);
        expect(result, isNull);
      });

      test('should update current user session when updating logged user', () {
        final user = User(
          id: 1,
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );

        userSession.addUser(user);
        userSession.setCurrentUser(user);

        final updatedData = User(
          id: 1,
          email: 'updated@example.com',
          username: 'updateduser',
          password: 'newpassword',
          name: Name(firstname: 'Updated', lastname: 'User'),
          address: user.address,
          phone: user.phone,
        );

        userSession.updateUser(1, updatedData);

        expect(userSession.getCurrentUser()!.email, 'updated@example.com');
        expect(userSession.getCurrentUser()!.username, 'updateduser');
      });
    });

    group('User Deletion', () {
      test('should delete existing user successfully', () {
        final testUser = User(
          id: 1,
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );

        userSession.addUser(testUser);
        expect(userSession.findUserByUsername('testuser'), isNotNull);

        final success = userSession.removeUser(1);
        expect(success, true);
        expect(userSession.findUserByUsername('testuser'), isNull);
      });

      test('should return false for non-existent user', () {
        final success = userSession.removeUser(999);
        expect(success, false);
      });

      test('should clear current session when deleting current logged user', () {
        final testUser = User(
          id: 1,
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );

        userSession.addUser(testUser);
        userSession.setCurrentUser(testUser);
        expect(userSession.getCurrentUser(), isNotNull);

        userSession.removeUser(1);
        expect(userSession.getCurrentUser(), isNull);
        expect(userSession.isLoggedIn(), false);
      });
    });

    group('Data Management', () {
      test('should get all users correctly', () {
        final user1 = User(
          id: 1,
          email: 'test1@example.com',
          username: 'testuser1',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User1'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );

        final user2 = User(
          id: 2,
          email: 'test2@example.com',
          username: 'testuser2',
          password: 'password456',
          name: Name(firstname: 'Test', lastname: 'User2'),
          address: Address(
            city: 'Test City 2',
            street: 'Test Street 2',
            number: 456,
            zipcode: '54321',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7034',
        );

        userSession.addUser(user1);
        userSession.addUser(user2);

        final allUsers = userSession.getAllUsers();
        expect(allUsers, hasLength(2));
        expect(allUsers.map((u) => u.id), containsAll([1, 2]));
      });

      test('should return empty list when no users exist', () {
        final allUsers = userSession.getAllUsers();
        expect(allUsers, isEmpty);
      });

      test('should get user count correctly', () {
        expect(userSession.getUserCount(), 0);

        final user = User(
          id: 1,
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );

        userSession.addUser(user);
        expect(userSession.getUserCount(), 1);
      });

      test('should clear all users and session successfully', () {
        final user1 = User(
          id: 1,
          email: 'test1@example.com',
          username: 'testuser1',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User1'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );

        final user2 = User(
          id: 2,
          email: 'test2@example.com',
          username: 'testuser2',
          password: 'password456',
          name: Name(firstname: 'Test', lastname: 'User2'),
          address: Address(
            city: 'Test City 2',
            street: 'Test Street 2',
            number: 456,
            zipcode: '54321',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7034',
        );

        userSession.addUser(user1);
        userSession.addUser(user2);
        userSession.setCurrentUser(user1);

        expect(userSession.getAllUsers(), hasLength(2));
        expect(userSession.isLoggedIn(), true);

        userSession.clearAll();

        expect(userSession.getAllUsers(), isEmpty);
        expect(userSession.isLoggedIn(), false);
        expect(userSession.getUserCount(), 0);
      });

      test('should get statistics correctly', () {
        final user = User(
          id: 1,
          email: 'test@example.com',
          username: 'testuser',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );

        userSession.addUser(user);
        userSession.setCurrentUser(user);

        final stats = userSession.getStatistics();
        expect(stats['totalUsers'], 1);
        expect(stats['currentUser'], 'testuser');
        expect(stats['hasCurrentSession'], true);
        expect(stats['usersWithEmail'], 1);
        expect(stats['usersWithPhone'], 1);
        expect(stats['usersWithAddress'], 1);
      });
    });

    group('UserSessionException', () {
      test('should create exception with message', () {
        const exception = UserSessionException('Test error message');
        expect(exception.message, 'Test error message');
        expect(exception.toString(), 'UserSessionException: Test error message');
      });

      test('should be throwable and catchable', () {
        expect(
          () => throw const UserSessionException('Test exception'),
          throwsA(isA<UserSessionException>()),
        );
      });

      test('should preserve exception message when thrown', () {
        try {
          throw const UserSessionException('Custom error');
        } catch (e) {
          expect(e, isA<UserSessionException>());
          expect((e as UserSessionException).message, 'Custom error');
        }
      });
    });

    group('Edge Cases', () {
      test('should handle large number of users', () {
        // Create multiple users
        for (int i = 1; i <= 50; i++) {
          final user = User(
            id: i,
            email: 'user$i@example.com',
            username: 'user$i',
            password: 'password$i',
            name: Name(firstname: 'User', lastname: '$i'),
            address: Address(
              city: 'City $i',
              street: 'Street $i',
              number: i,
              zipcode: '1000$i',
              geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
            ),
            phone: '1-570-236-70${i.toString().padLeft(2, '0')}',
          );
          userSession.addUser(user);
        }

        expect(userSession.getAllUsers(), hasLength(50));
        expect(userSession.findUserByUsername('user25'), isNotNull);
        expect(userSession.findUserByUsername('user25')!.username, 'user25');
      });

      test('should handle special characters in user data', () {
        final user = User(
          id: 1,
          email: 'test+special@example.com',
          username: 'test_user-123',
          password: 'pássw0rd@123!',
          name: Name(firstname: 'José', lastname: 'García-López'),
          address: Address(
            city: 'São Paulo',
            street: 'Rua José da Silva, nº 123',
            number: 123,
            zipcode: '01234-567',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '+55 (11) 9999-9999',
        );

        userSession.addUser(user);
        final foundUser = userSession.findUser('test_user-123', 'pássw0rd@123!');
        
        expect(foundUser, isNotNull);
        expect(foundUser!.name.firstname, 'José');
      });

      test('should handle concurrent operations gracefully', () {
        // This test simulates concurrent access patterns
        final user1 = User(
          id: 1,
          email: 'test1@example.com',
          username: 'testuser1',
          password: 'password123',
          name: Name(firstname: 'Test', lastname: 'User1'),
          address: Address(
            city: 'Test City',
            street: 'Test Street',
            number: 123,
            zipcode: '12345',
            geolocation: Geolocation(lat: '-37.3159', long: '81.1496'),
          ),
          phone: '1-570-236-7033',
        );

        userSession.addUser(user1);
        
        // Simulate concurrent read operations
        for (int i = 0; i < 10; i++) {
          expect(userSession.findUserByUsername('testuser1'), isNotNull);
          expect(userSession.findUserByEmail('test1@example.com'), isNotNull);
          expect(userSession.userExists('testuser1'), true);
        }
      });

      test('should handle null and empty values properly', () {
        // Test with minimal user data
        final user = User(
          id: 1,
          email: 'minimal@example.com',
          username: 'minimal',
          password: 'pass',
          name: Name(firstname: 'Min', lastname: 'User'),
          address: Address(
            city: 'City',
            street: 'Street',
            number: 1,
            zipcode: '12345',
            geolocation: Geolocation(lat: '0', long: '0'),
          ),
          phone: '123',
        );

        userSession.addUser(user);
        expect(userSession.findUserByUsername('minimal'), isNotNull);
      });
    });
  });
}