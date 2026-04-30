import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/auth/presentation/cubit/auth_cubit.dart';

import '../../../../mocks/mocks.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/core/enums/request_status.dart';
import 'package:app/features/auth/domain/entities/app_user.dart';
import 'package:app/features/auth/presentation/cubit/auth_state.dart';

import '../../../../fixtures/auth_fixtures.dart';

void main() {
  /// Group for testing AuthCubit - handles all authentication logic
  group('AuthCubit', () {
    late MockWatchAuthenticatedUserUseCase mockWatchAuthenticatedUserUseCase;
    late MockSignUpWithEmailUseCase mockSignUpWithEmailUseCase;
    late MockSignInWithEmailUseCase mockSignInWithEmailUseCase;
    late MockSignInWithGoogleUseCase mockSignInWithGoogleUseCase;
    late MockSaveUserRoleUseCase mockSaveUserRoleUseCase;
    late MockSignOutUseCase mockSignOutUseCase;
    late AuthCubit authCubit;

    setUp(() {
      mockWatchAuthenticatedUserUseCase = MockWatchAuthenticatedUserUseCase();
      mockSignUpWithEmailUseCase = MockSignUpWithEmailUseCase();
      mockSignInWithEmailUseCase = MockSignInWithEmailUseCase();
      mockSignInWithGoogleUseCase = MockSignInWithGoogleUseCase();
      mockSaveUserRoleUseCase = MockSaveUserRoleUseCase();
      mockSignOutUseCase = MockSignOutUseCase();

      authCubit = AuthCubit(
        watchAuthenticatedUserUseCase: mockWatchAuthenticatedUserUseCase,
        signUpWithEmailUseCase: mockSignUpWithEmailUseCase,
        signInWithEmailUseCase: mockSignInWithEmailUseCase,
        signInWithGoogleUseCase: mockSignInWithGoogleUseCase,
        saveUserRoleUseCase: mockSaveUserRoleUseCase,
        signOutUseCase: mockSignOutUseCase,
      );
    });

    tearDown(() async {
      await authCubit.close();
    });
    // ==================== Initial State Tests ====================
    group('Initial State', () {
      /// Test: AuthCubit should emit initial state when created
      test(
        'AuthCubit initial state should be AuthState with initial status',
        () {
          expect(
            authCubit.state,
            const AuthState(
              status: RequestStatus.initial,
              user: null,
              errorMessage: null,
            ),
          );
        },
      );
    });

    // ==================== startListening Tests ====================
    group('startListening', () {
      /// Test: Should emit success state when user is available
      blocTest<AuthCubit, AuthState>(
        'Should emit success state with user when watch returns user',
        setUp: () {
          when(
            () => mockWatchAuthenticatedUserUseCase(),
          ).thenAnswer((_) => Stream.value(AuthFixtures.sampleAppUser));
        },
        build: () => authCubit,
        act: (cubit) => cubit.startListening(),
        expect:
            () => [
              AuthState(
                status: RequestStatus.success,
                user: AuthFixtures.sampleAppUser,
                errorMessage: null,
              ),
            ],
      );

      /// Test: Should emit initial state when user is null (logged out)
      blocTest<AuthCubit, AuthState>(
        'Should emit initial state when no authenticated user',
        setUp: () {
          when(
            () => mockWatchAuthenticatedUserUseCase(),
          ).thenAnswer((_) => Stream.value(null));
        },
        build: () => authCubit,
        act: (cubit) => cubit.startListening(),
        expect:
            () => [
              const AuthState(
                status: RequestStatus.initial,
                user: null,
                errorMessage: null,
              ),
            ],
      );

      /// Test: Should emit failure state when error occurs
      blocTest<AuthCubit, AuthState>(
        'Should emit failure state with error message on stream error',
        setUp: () {
          when(
            () => mockWatchAuthenticatedUserUseCase(),
          ).thenAnswer((_) => Stream.error(Exception('Auth stream error')));
        },
        build: () => authCubit,
        act: (cubit) => cubit.startListening(),
        expect:
            () => [
              isA<AuthState>()
                  .having(
                    (state) => state.status,
                    'status',
                    RequestStatus.failure,
                  )
                  .having(
                    (state) => state.errorMessage,
                    'errorMessage',
                    contains('Auth stream error'),
                  ),
            ],
      );
    });

    // ==================== signUpWithEmail Tests ====================
    group('signUpWithEmail', () {
      /// Test: Should successfully sign up and emit success state
      blocTest<AuthCubit, AuthState>(
        'Should emit loading then success state on successful sign up',
        setUp: () {
          when(
            () => mockSignUpWithEmailUseCase(
              name: any(named: 'name'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => AuthFixtures.sampleUnknownRoleUser);
        },
        build: () => authCubit,
        act:
            (cubit) => cubit.signUpWithEmail(
              name: AuthFixtures.testName,
              email: AuthFixtures.testEmail,
              password: AuthFixtures.testPassword,
            ),
        expect:
            () => [
              // Loading state
              isA<AuthState>().having(
                (state) => state.status,
                'status',
                RequestStatus.loading,
              ),
              // Success state
              isA<AuthState>()
                  .having(
                    (state) => state.status,
                    'status',
                    RequestStatus.success,
                  )
                  .having(
                    (state) => state.user,
                    'user',
                    AuthFixtures.sampleUnknownRoleUser,
                  )
                  .having((state) => state.errorMessage, 'errorMessage', null),
            ],
      );

      /// Test: Should emit failure state when email is already in use
      blocTest<AuthCubit, AuthState>(
        'Should emit loading then failure state when email exists',
        setUp: () {
          when(
            () => mockSignUpWithEmailUseCase(
              name: any(named: 'name'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(Exception(CommonFixtures.emailAlreadyInUseError));
        },
        build: () => authCubit,
        act:
            (cubit) => cubit.signUpWithEmail(
              name: AuthFixtures.testName,
              email: AuthFixtures.testEmail,
              password: AuthFixtures.testPassword,
            ),
        expect:
            () => [
              isA<AuthState>().having(
                (state) => state.status,
                'status',
                RequestStatus.loading,
              ),
              isA<AuthState>()
                  .having(
                    (state) => state.status,
                    'status',
                    RequestStatus.failure,
                  )
                  .having(
                    (state) => state.errorMessage,
                    'errorMessage',
                    contains(CommonFixtures.emailAlreadyInUseError),
                  ),
            ],
      );

      /// Test: Should emit failure state when sign up fails
      blocTest<AuthCubit, AuthState>(
        'Should emit failure state on sign up error',
        setUp: () {
          when(
            () => mockSignUpWithEmailUseCase(
              name: any(named: 'name'),
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(Exception('Network error'));
        },
        build: () => authCubit,
        act:
            (cubit) => cubit.signUpWithEmail(
              name: AuthFixtures.testName,
              email: AuthFixtures.testEmail,
              password: AuthFixtures.testPassword,
            ),
        expect:
            () => [
              isA<AuthState>().having(
                (state) => state.status,
                'status',
                RequestStatus.loading,
              ),
              isA<AuthState>()
                  .having(
                    (state) => state.status,
                    'status',
                    RequestStatus.failure,
                  )
                  .having(
                    (state) => state.errorMessage,
                    'errorMessage',
                    contains('Network error'),
                  ),
            ],
      );
    });

    // ==================== signInWithEmail Tests ====================
    group('signInWithEmail', () {
      /// Test: Should successfully sign in and emit success state
      blocTest<AuthCubit, AuthState>(
        'Should emit loading then success state on successful sign in',
        setUp: () {
          when(
            () => mockSignInWithEmailUseCase(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => {});
        },
        build: () => authCubit,
        act:
            (cubit) => cubit.signInWithEmail(
              email: AuthFixtures.testEmail,
              password: AuthFixtures.testPassword,
            ),
        expect:
            () => [
              isA<AuthState>().having(
                (state) => state.status,
                'status',
                RequestStatus.loading,
              ),
              isA<AuthState>().having(
                (state) => state.status,
                'status',
                RequestStatus.success,
              ),
            ],
      );

      /// Test: Should emit failure state on invalid credentials
      blocTest<AuthCubit, AuthState>(
        'Should emit failure state on invalid credentials',
        setUp: () {
          when(
            () => mockSignInWithEmailUseCase(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(Exception('Invalid email or password'));
        },
        build: () => authCubit,
        act:
            (cubit) => cubit.signInWithEmail(
              email: AuthFixtures.testEmail,
              password: 'wrongpassword',
            ),
        expect:
            () => [
              isA<AuthState>().having(
                (state) => state.status,
                'status',
                RequestStatus.loading,
              ),
              isA<AuthState>()
                  .having(
                    (state) => state.status,
                    'status',
                    RequestStatus.failure,
                  )
                  .having(
                    (state) => state.errorMessage,
                    'errorMessage',
                    contains('Invalid email or password'),
                  ),
            ],
      );
    });

    // ==================== signInWithGoogle Tests ====================
    group('signInWithGoogle', () {
      /// Test: Should successfully sign in with Google
      blocTest<AuthCubit, AuthState>(
        'Should emit loading state on Google sign in',
        setUp: () {
          when(() => mockSignInWithGoogleUseCase()).thenAnswer((_) async => {});
        },
        build: () => authCubit,
        act: (cubit) => cubit.signInWithGoogle(),
        expect:
            () => [
              isA<AuthState>().having(
                (state) => state.status,
                'status',
                RequestStatus.loading,
              ),
            ],
      );

      /// Test: Should emit failure state when Google sign in is cancelled
      blocTest<AuthCubit, AuthState>(
        'Should emit failure state when Google sign in fails',
        setUp: () {
          when(
            () => mockSignInWithGoogleUseCase(),
          ).thenThrow(Exception('Google sign in cancelled'));
        },
        build: () => authCubit,
        act: (cubit) => cubit.signInWithGoogle(),
        expect:
            () => [
              isA<AuthState>().having(
                (state) => state.status,
                'status',
                RequestStatus.loading,
              ),
              isA<AuthState>()
                  .having(
                    (state) => state.status,
                    'status',
                    RequestStatus.failure,
                  )
                  .having(
                    (state) => state.errorMessage,
                    'errorMessage',
                    contains('Google sign in cancelled'),
                  ),
            ],
      );
    });

    // ==================== saveRole Tests ====================
    group('saveRole', () {
      /// Test: Should successfully save student role
      blocTest<AuthCubit, AuthState>(
        'Should emit success state after saving student role',
        setUp: () {
          when(
            () => mockSaveUserRoleUseCase(UserRole.student),
          ).thenAnswer((_) async => {});
        },
        build: () => authCubit,
        act: (cubit) => cubit.saveRole(UserRole.student),
        expect:
            () => [
              isA<AuthState>().having(
                (state) => state.status,
                'status',
                RequestStatus.loading,
              ),
            ],
      );

      /// Test: Should successfully save tutor role
      blocTest<AuthCubit, AuthState>(
        'Should emit success state after saving tutor role',
        setUp: () {
          when(
            () => mockSaveUserRoleUseCase(UserRole.tutor),
          ).thenAnswer((_) async => {});
        },
        build: () => authCubit,
        act: (cubit) => cubit.saveRole(UserRole.tutor),
        expect:
            () => [
              isA<AuthState>().having(
                (state) => state.status,
                'status',
                RequestStatus.loading,
              ),
            ],
      );

      /// Test: Should emit failure state when save fails
      blocTest<AuthCubit, AuthState>(
        'Should emit failure state when role save fails',
        setUp: () {
          when(
            () => mockSaveUserRoleUseCase(UserRole.student),
          ).thenThrow(Exception('Firestore write failed'));
        },
        build: () => authCubit,
        act: (cubit) => cubit.saveRole(UserRole.student),
        expect:
            () => [
              isA<AuthState>().having(
                (state) => state.status,
                'status',
                RequestStatus.loading,
              ),
              isA<AuthState>()
                  .having(
                    (state) => state.status,
                    'status',
                    RequestStatus.failure,
                  )
                  .having(
                    (state) => state.errorMessage,
                    'errorMessage',
                    contains('Firestore write failed'),
                  ),
            ],
      );
    });

    // ==================== signOut Tests ====================
    group('signOut', () {
      /// Test: Should successfully sign out
      blocTest<AuthCubit, AuthState>(
        'Should call sign out use case',
        setUp: () {
          when(() => mockSignOutUseCase()).thenAnswer((_) async => {});
        },
        build: () => authCubit,
        act: (cubit) => cubit.signOut(),
        expect: () => [],
      );
    });

    // ==================== isAuthenticated Tests ====================
    group('isAuthenticated', () {
      /// Test: Should return true when user is not null
      test('Should return true when user is authenticated', () {
        final state = AuthState(
          status: RequestStatus.success,
          user: AuthFixtures.sampleAppUser,
          errorMessage: null,
        );
        expect(state.isAuthenticated, true);
      });

      /// Test: Should return false when user is null
      test('Should return false when user is not authenticated', () {
        const state = AuthState(
          status: RequestStatus.initial,
          user: null,
          errorMessage: null,
        );
        expect(state.isAuthenticated, false);
      });
    });
  });
}
