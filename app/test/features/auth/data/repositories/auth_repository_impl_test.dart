import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app/features/auth/data/models/app_user_model.dart';
import 'package:app/features/auth/domain/entities/app_user.dart';

import '../../../../fixtures/auth_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  group('AuthRepositoryImpl', () {
    late MockAuthRemoteDataSource mockRemoteDataSource;
    late AuthRepositoryImpl repository;

    setUp(() {
      mockRemoteDataSource = MockAuthRemoteDataSource();
      repository = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
      );
    });

    // ==================== signUpWithEmail ====================
    group('signUpWithEmail', () {
      test('Should call remoteDataSource.signUpWithEmail and return AppUser',
          () async {
        // Arrange
        final testModel = AuthFixtures.sampleAppUserModel;
        when(() => mockRemoteDataSource.signUpWithEmail(
              name: AuthFixtures.testName,
              email: AuthFixtures.testEmail,
              password: AuthFixtures.testPassword,
            )).thenAnswer((_) async => testModel);

        // Act
        final result = await repository.signUpWithEmail(
          name: AuthFixtures.testName,
          email: AuthFixtures.testEmail,
          password: AuthFixtures.testPassword,
        );

        // Assert
        expect(result, isA<AppUser>());
        expect(result.email, AuthFixtures.testEmail);
        expect(result.name, AuthFixtures.testName);
        verify(() => mockRemoteDataSource.signUpWithEmail(
              name: AuthFixtures.testName,
              email: AuthFixtures.testEmail,
              password: AuthFixtures.testPassword,
            )).called(1);
      });

      test('Should propagate error when sign up fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.signUpWithEmail(
              name: any(named: 'name'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Email already in use'));

        // Act & Assert
        expect(
          () => repository.signUpWithEmail(
            name: AuthFixtures.testName,
            email: AuthFixtures.testEmail,
            password: AuthFixtures.testPassword,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ==================== signInWithEmail ====================
    group('signInWithEmail', () {
      test('Should delegate to remoteDataSource.signInWithEmail', () async {
        // Arrange
        when(() => mockRemoteDataSource.signInWithEmail(
              email: AuthFixtures.testEmail,
              password: AuthFixtures.testPassword,
            )).thenAnswer((_) async {});

        // Act
        await repository.signInWithEmail(
          email: AuthFixtures.testEmail,
          password: AuthFixtures.testPassword,
        );

        // Assert
        verify(() => mockRemoteDataSource.signInWithEmail(
              email: AuthFixtures.testEmail,
              password: AuthFixtures.testPassword,
            )).called(1);
      });

      test('Should propagate error when sign in fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.signInWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Invalid credentials'));

        // Act & Assert
        expect(
          () => repository.signInWithEmail(
            email: 'wrong@example.com',
            password: 'wrongpass',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ==================== signInWithGoogle ====================
    group('signInWithGoogle', () {
      test('Should delegate to remoteDataSource.signInWithGoogle', () async {
        // Arrange
        when(() => mockRemoteDataSource.signInWithGoogle())
            .thenAnswer((_) async {});

        // Act
        await repository.signInWithGoogle();

        // Assert
        verify(() => mockRemoteDataSource.signInWithGoogle()).called(1);
      });

      test('Should propagate error when Google sign in fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.signInWithGoogle())
            .thenThrow(Exception('Google sign in was cancelled.'));

        // Act & Assert
        expect(
          () => repository.signInWithGoogle(),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ==================== saveRole ====================
    group('saveRole', () {
      test('Should delegate to remoteDataSource.saveRole', () async {
        // Arrange
        when(() => mockRemoteDataSource.saveRole(UserRole.student))
            .thenAnswer((_) async {});

        // Act
        await repository.saveRole(UserRole.student);

        // Assert
        verify(() => mockRemoteDataSource.saveRole(UserRole.student)).called(1);
      });

      test('Should work with tutor role', () async {
        // Arrange
        when(() => mockRemoteDataSource.saveRole(UserRole.tutor))
            .thenAnswer((_) async {});

        // Act
        await repository.saveRole(UserRole.tutor);

        // Assert
        verify(() => mockRemoteDataSource.saveRole(UserRole.tutor)).called(1);
      });

      test('Should propagate error when saveRole fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.saveRole(any()))
            .thenThrow(Exception('No authenticated user found.'));

        // Act & Assert
        expect(
          () => repository.saveRole(UserRole.student),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ==================== signOut ====================
    group('signOut', () {
      test('Should delegate to remoteDataSource.signOut', () async {
        // Arrange
        when(() => mockRemoteDataSource.signOut())
            .thenAnswer((_) async {});

        // Act
        await repository.signOut();

        // Assert
        verify(() => mockRemoteDataSource.signOut()).called(1);
      });

      test('Should propagate error when sign out fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.signOut())
            .thenThrow(Exception('Sign out failed'));

        // Act & Assert
        expect(
          () => repository.signOut(),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ==================== watchAuthUser ====================
    group('watchAuthUser', () {
      test('Should return a broadcast stream', () {
        // Arrange
        final mockUser = MockUser();
        when(() => mockRemoteDataSource.authStateChanges())
            .thenAnswer((_) => Stream.value(mockUser));
        when(() => mockRemoteDataSource.ensureUserDocument(any()))
            .thenAnswer((_) async {});
        when(() => mockRemoteDataSource.watchUserProfile(any()))
            .thenAnswer((_) => Stream.value(AuthFixtures.sampleAppUserModel));

        // Act
        final result = repository.watchAuthUser();

        // Assert
        expect(result, isA<Stream<AppUser?>>());
      });

      test('Should emit null when Firebase user is null', () async {
        // Arrange
        when(() => mockRemoteDataSource.authStateChanges())
            .thenAnswer((_) => Stream.value(null));

        // Act
        final stream = repository.watchAuthUser();

        // Assert
        await expectLater(stream, emits(isNull));
      });
    });
  });
}
