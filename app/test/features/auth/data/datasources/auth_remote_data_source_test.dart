import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:app/features/auth/data/models/app_user_model.dart';
import 'package:app/features/auth/domain/entities/app_user.dart';

import '../../../../fixtures/auth_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  group('AuthRemoteDataSource', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFirebaseFirestore mockFirebaseFirestore;
    late MockGoogleSignIn mockGoogleSignIn;
    late AuthRemoteDataSource dataSource;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockFirebaseFirestore = MockFirebaseFirestore();
      mockGoogleSignIn = MockGoogleSignIn();
      dataSource = AuthRemoteDataSource(
        auth: mockFirebaseAuth,
        firestore: mockFirebaseFirestore,
        googleSignIn: mockGoogleSignIn,
      );
    });

    // ==================== authStateChanges ====================
    group('authStateChanges', () {
      test('Should return auth state changes stream from FirebaseAuth', () {
        // Arrange
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(mockUser));

        // Act
        final result = dataSource.authStateChanges();

        // Assert
        expect(result, emits(isA<User>()));
        verify(() => mockFirebaseAuth.authStateChanges()).called(1);
      });

      test('Should emit null when user is signed out', () {
        // Arrange
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(null));

        // Act
        final result = dataSource.authStateChanges();

        // Assert
        expect(result, emits(isNull));
      });
    });

    // ==================== signUpWithEmail ====================
    group('signUpWithEmail', () {
      test('Should return AppUserModel on successful sign up', () async {
        // Arrange
        final mockUserCredential = MockUserCredential();
        final mockUser = MockUser();

        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: AuthFixtures.testEmail,
              password: AuthFixtures.testPassword,
            )).thenAnswer((_) async => mockUserCredential);

        when(() => mockUserCredential.user).thenReturn(mockUser);
        when(() => mockUser.updateDisplayName(AuthFixtures.testName))
            .thenAnswer((_) async {});

        final mockCollectionRef = MockCollectionReference();
        final mockDocRef = MockDocumentReference();

        when(() => mockFirebaseFirestore.collection(any()))
            .thenReturn(mockCollectionRef as dynamic);
        when(() => (mockCollectionRef as dynamic).doc(any()))
            .thenReturn(mockDocRef);
        when(() => (mockDocRef as dynamic).set(any(), any()))
            .thenAnswer((_) async {});

        // Act
        final result = await dataSource.signUpWithEmail(
          name: AuthFixtures.testName,
          email: AuthFixtures.testEmail,
          password: AuthFixtures.testPassword,
        );

        // Assert
        expect(result, isA<AppUserModel>());
        expect(result.email, AuthFixtures.testEmail);
        expect(result.name, AuthFixtures.testName);
        expect(result.role, UserRole.unknown);
      });

      test('Should throw exception when user creation returns null', () async {
        // Arrange
        final mockUserCredential = MockUserCredential();

        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: AuthFixtures.testEmail,
              password: AuthFixtures.testPassword,
            )).thenAnswer((_) async => mockUserCredential);

        when(() => mockUserCredential.user).thenReturn(null);

        // Act & Assert
        expect(
          () => dataSource.signUpWithEmail(
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
      test('Should call signInWithEmailAndPassword on FirebaseAuth', () async {
        // Arrange
        final mockUserCredential = MockUserCredential();
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: AuthFixtures.testEmail,
              password: AuthFixtures.testPassword,
            )).thenAnswer((_) async => mockUserCredential);

        // Act
        await dataSource.signInWithEmail(
          email: AuthFixtures.testEmail,
          password: AuthFixtures.testPassword,
        );

        // Assert
        verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: AuthFixtures.testEmail,
              password: AuthFixtures.testPassword,
            )).called(1);
      });

      test('Should propagate error when sign in fails', () async {
        // Arrange
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Invalid credentials'));

        // Act & Assert
        expect(
          () => dataSource.signInWithEmail(
            email: 'wrong@example.com',
            password: 'wrongpass',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ==================== signInWithGoogle ====================
    group('signInWithGoogle', () {
      test('Should throw exception when Google sign in is cancelled', () async {
        // Arrange
        when(() => mockGoogleSignIn.signIn())
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => dataSource.signInWithGoogle(),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ==================== signOut ====================
    group('signOut', () {
      test('Should call signOut on both GoogleSignIn and FirebaseAuth', () async {
        // Arrange
        when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        // Act
        await dataSource.signOut();

        // Assert
        verify(() => mockGoogleSignIn.signOut()).called(1);
        verify(() => mockFirebaseAuth.signOut()).called(1);
      });
    });

    // ==================== saveRole ====================
    group('saveRole', () {
      test('Should throw exception when no user is authenticated', () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => dataSource.saveRole(UserRole.student),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
