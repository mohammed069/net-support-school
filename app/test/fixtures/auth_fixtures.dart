import 'package:app/features/auth/domain/entities/app_user.dart';
import 'package:app/features/auth/data/models/app_user_model.dart';

/// Test fixtures for Auth feature
class AuthFixtures {
  // Test user data
  static const testUserId = 'test-user-id-123';
  static const testEmail = 'testuser@example.com';
  static const testName = 'Test User';
  static const testPassword = 'password123';
  static const testPhotoUrl = 'https://example.com/photo.jpg';

  /// Sample AppUser entity for testing
  static AppUser get sampleAppUser {
    return const AppUser(
      id: testUserId,
      email: testEmail,
      name: testName,
      role: UserRole.student,
      photoUrl: testPhotoUrl,
      createdAt: null,
    );
  }

  /// Sample AppUserModel for testing repository/datasource
  static AppUserModel get sampleAppUserModel {
    return AppUserModel(
      id: testUserId,
      email: testEmail,
      name: testName,
      role: UserRole.student,
      photoUrl: testPhotoUrl,
      createdAt: DateTime.now(),
    );
  }

  /// Sample tutor user
  static AppUser get sampleTutorUser {
    return const AppUser(
      id: 'tutor-id-456',
      email: 'tutor@example.com',
      name: 'Test Tutor',
      role: UserRole.tutor,
      photoUrl: null,
      createdAt: null,
    );
  }

  /// Sample unknown role user (during registration)
  static AppUser get sampleUnknownRoleUser {
    return const AppUser(
      id: 'new-user-id',
      email: testEmail,
      name: testName,
      role: UserRole.unknown,
      photoUrl: null,
      createdAt: null,
    );
  }

  /// Sample null user (logged out state)
  static AppUser? get nullUser => null;
}

/// Test fixtures for common scenarios
class CommonFixtures {
  static const String testErrorMessage = 'An unexpected error occurred';
  static const String emailAlreadyInUseError =
      'The email is already in use. Try signing in instead.';
  static const String invalidEmailError = 'Invalid email address format';
  static const String weakPasswordError =
      'Password should be at least 6 characters';
  static const String networkError = 'Network connection failed';

  static String getFirebaseErrorMessage(String code) {
    final messages = {
      'email-already-in-use': emailAlreadyInUseError,
      'invalid-email': invalidEmailError,
      'weak-password': weakPasswordError,
      'network-error': networkError,
    };
    return messages[code] ?? testErrorMessage;
  }
}
