import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/auth/domain/entities/app_user.dart';
import 'package:app/features/auth/domain/usecases/auth_usecases.dart';

import '../../../../fixtures/auth_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  group('Auth UseCases', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    // ==================== WatchAuthenticatedUserUseCase ====================
    group('WatchAuthenticatedUserUseCase', () {
      late WatchAuthenticatedUserUseCase useCase;

      setUp(() {
        useCase = WatchAuthenticatedUserUseCase(mockAuthRepository);
      });

      test('Should return stream of AppUser from repository', () {
        // Arrange
        final testUser = AuthFixtures.sampleAppUser;
        when(() => mockAuthRepository.watchAuthUser())
            .thenAnswer((_) => Stream.value(testUser));

        // Act
        final result = useCase();

        // Assert
        expect(result, emits(testUser));
        verify(() => mockAuthRepository.watchAuthUser()).called(1);
      });

      test('Should emit null when user is not authenticated', () {
        // Arrange
        when(() => mockAuthRepository.watchAuthUser())
            .thenAnswer((_) => Stream.value(null));

        // Act
        final result = useCase();

        // Assert
        expect(result, emits(isNull));
      });

      test('Should propagate errors from repository stream', () {
        // Arrange
        when(() => mockAuthRepository.watchAuthUser())
            .thenAnswer((_) => Stream.error(Exception('Stream error')));

        // Act
        final result = useCase();

        // Assert
        expect(result, emitsError(isA<Exception>()));
      });
    });

    // ==================== SignUpWithEmailUseCase ====================
    group('SignUpWithEmailUseCase', () {
      late SignUpWithEmailUseCase useCase;

      setUp(() {
        useCase = SignUpWithEmailUseCase(mockAuthRepository);
      });

      test('Should return AppUser on successful sign up', () async {
        // Arrange
        final testUser = AuthFixtures.sampleAppUser;
        when(() => mockAuthRepository.signUpWithEmail(
              name: AuthFixtures.testName,
              email: AuthFixtures.testEmail,
              password: AuthFixtures.testPassword,
            )).thenAnswer((_) async => testUser);

        // Act
        final result = await useCase(
          name: AuthFixtures.testName,
          email: AuthFixtures.testEmail,
          password: AuthFixtures.testPassword,
        );

        // Assert
        expect(result, testUser);
        expect(result.email, AuthFixtures.testEmail);
        expect(result.name, AuthFixtures.testName);
        verify(() => mockAuthRepository.signUpWithEmail(
              name: AuthFixtures.testName,
              email: AuthFixtures.testEmail,
              password: AuthFixtures.testPassword,
            )).called(1);
      });

      test('Should propagate error when sign up fails', () async {
        // Arrange
        when(() => mockAuthRepository.signUpWithEmail(
              name: any(named: 'name'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Email already in use'));

        // Act & Assert
        expect(
          () => useCase(
            name: AuthFixtures.testName,
            email: AuthFixtures.testEmail,
            password: AuthFixtures.testPassword,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ==================== SignInWithEmailUseCase ====================
    group('SignInWithEmailUseCase', () {
      late SignInWithEmailUseCase useCase;

      setUp(() {
        useCase = SignInWithEmailUseCase(mockAuthRepository);
      });

      test('Should call repository signInWithEmail with correct params',
          () async {
        // Arrange
        when(() => mockAuthRepository.signInWithEmail(
              email: AuthFixtures.testEmail,
              password: AuthFixtures.testPassword,
            )).thenAnswer((_) async {});

        // Act
        await useCase(
          email: AuthFixtures.testEmail,
          password: AuthFixtures.testPassword,
        );

        // Assert
        verify(() => mockAuthRepository.signInWithEmail(
              email: AuthFixtures.testEmail,
              password: AuthFixtures.testPassword,
            )).called(1);
      });

      test('Should propagate error when sign in fails', () async {
        // Arrange
        when(() => mockAuthRepository.signInWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Invalid credentials'));

        // Act & Assert
        expect(
          () => useCase(
            email: 'wrong@example.com',
            password: 'wrongpass',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ==================== SignInWithGoogleUseCase ====================
    group('SignInWithGoogleUseCase', () {
      late SignInWithGoogleUseCase useCase;

      setUp(() {
        useCase = SignInWithGoogleUseCase(mockAuthRepository);
      });

      test('Should call repository signInWithGoogle', () async {
        // Arrange
        when(() => mockAuthRepository.signInWithGoogle())
            .thenAnswer((_) async {});

        // Act
        await useCase();

        // Assert
        verify(() => mockAuthRepository.signInWithGoogle()).called(1);
      });

      test('Should propagate error when Google sign in fails', () async {
        // Arrange
        when(() => mockAuthRepository.signInWithGoogle())
            .thenThrow(Exception('Google sign in was cancelled.'));

        // Act & Assert
        expect(
          () => useCase(),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ==================== SaveUserRoleUseCase ====================
    group('SaveUserRoleUseCase', () {
      late SaveUserRoleUseCase useCase;

      setUp(() {
        useCase = SaveUserRoleUseCase(mockAuthRepository);
      });

      test('Should call repository saveRole with student role', () async {
        // Arrange
        when(() => mockAuthRepository.saveRole(UserRole.student))
            .thenAnswer((_) async {});

        // Act
        await useCase(UserRole.student);

        // Assert
        verify(() => mockAuthRepository.saveRole(UserRole.student)).called(1);
      });

      test('Should call repository saveRole with tutor role', () async {
        // Arrange
        when(() => mockAuthRepository.saveRole(UserRole.tutor))
            .thenAnswer((_) async {});

        // Act
        await useCase(UserRole.tutor);

        // Assert
        verify(() => mockAuthRepository.saveRole(UserRole.tutor)).called(1);
      });

      test('Should propagate error when saveRole fails', () async {
        // Arrange
        when(() => mockAuthRepository.saveRole(any()))
            .thenThrow(Exception('No authenticated user'));

        // Act & Assert
        expect(
          () => useCase(UserRole.student),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ==================== SignOutUseCase ====================
    group('SignOutUseCase', () {
      late SignOutUseCase useCase;

      setUp(() {
        useCase = SignOutUseCase(mockAuthRepository);
      });

      test('Should call repository signOut', () async {
        // Arrange
        when(() => mockAuthRepository.signOut())
            .thenAnswer((_) async {});

        // Act
        await useCase();

        // Assert
        verify(() => mockAuthRepository.signOut()).called(1);
      });

      test('Should propagate error when sign out fails', () async {
        // Arrange
        when(() => mockAuthRepository.signOut())
            .thenThrow(Exception('Sign out failed'));

        // Act & Assert
        expect(
          () => useCase(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
