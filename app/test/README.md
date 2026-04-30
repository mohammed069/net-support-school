# Testing Suite for Net Support School App

This directory contains a comprehensive testing suite for the Net Support School Flutter application. The tests follow Clean Architecture principles and are organized to mirror the `lib` folder structure.

## 📁 Test Structure

```
test/
├── fixtures/                    # Test data factories
│   └── auth_fixtures.dart      # Auth feature test data
├── mocks/                       # Mock/Stub classes
│   └── mocks.dart              # All mock implementations
├── core/                        # Core feature tests
│   ├── services/
│   │   └── firebase_bootstrap_test.dart
│   └── di/
│       └── injection_container_test.dart
├── features/                    # Feature tests (mirrors lib/features)
│   ├── auth/
│   │   ├── presentation/cubit/
│   │   │   └── auth_cubit_test.dart           ✅ FULLY IMPLEMENTED
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_data_source_test.dart  ✅ FULLY IMPLEMENTED
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl_test.dart     ✅ FULLY IMPLEMENTED
│   │   └── domain/usecases/
│   │       └── auth_usecases_test.dart        ✅ FULLY IMPLEMENTED
│   ├── exam/
│   │   ├── presentation/cubit/
│   │   │   └── exam_cubit_test.dart           📝 TEMPLATE
│   │   └── ...
│   ├── student/
│   │   ├── presentation/cubit/
│   │   │   └── student_cubit_test.dart        📝 TEMPLATE
│   │   └── ...
│   ├── tutor/
│   │   ├── presentation/cubit/
│   │   │   └── tutor_cubit_test.dart          📝 TEMPLATE
│   │   └── ...
│   └── settings/
└── shared/
    └── widgets/
        └── shared_widgets_test.dart           📝 TEMPLATE

Legend:
✅ FULLY IMPLEMENTED - Ready to use and extend
📝 TEMPLATE - Template provided, needs completion
```

## 🎯 Test Categories

### Unit Tests

- **Domain Layer**: Use case logic and business rules
- **Data Layer**: Repository implementations and data sources
- **Core Services**: Firebase bootstrap and dependency injection

### Bloc/Cubit Tests

- **Presentation Layer**: State management with Cubit
- Uses `bloc_test` for testing state transitions

### Fixtures

- **Test Data Factories**: Reusable test data for consistent testing

### Mocks

- **Firebase Mocks**: Mock Firebase Auth, Firestore, Google Sign-In
- **Repository/DataSource Mocks**: For isolating layers

## 📚 Testing Patterns

### 1. **Mocking with Mocktail**

```dart
final mockRepository = MockAuthRepository();
when(() => mockRepository.signInWithEmail(
  email: 'test@example.com',
  password: 'password',
)).thenAnswer((_) async => user);
```

### 2. **Fixtures for Test Data**

```dart
final user = AuthFixtures.sampleAppUser;
final email = AuthFixtures.testEmail;
```

### 3. **Bloc/Cubit Testing**

```dart
blocTest<AuthCubit, AuthState>(
  'Should emit success state on successful login',
  setUp: () { /* setup mocks */ },
  build: () => authCubit,
  act: (cubit) => cubit.signInWithEmail(...),
  expect: () => [
    AuthState(status: RequestStatus.loading),
    AuthState(status: RequestStatus.success, user: testUser),
  ],
);
```

### 4. **Clear Test Naming & Grouping**

```dart
group('SignUpWithEmailUseCase', () {
  group('Validation Tests', () {
    test('Should validate email format', () { ... });
  });

  group('API Interaction', () {
    test('Should call repository with correct parameters', () { ... });
  });
});
```

## 🚀 Running Tests

### Run all tests:

```bash
flutter test
```

### Run specific test file:

```bash
flutter test test/features/auth/presentation/cubit/auth_cubit_test.dart
```

### Run tests with coverage:

```bash
flutter test --coverage
```

### Run specific test by name:

```bash
flutter test -k "SignUpWithEmail"
```

### Run tests in watch mode:

```bash
flutter test --watch
```

## 📝 Writing Tests

### Best Practices

1. **Clear Test Names**: Describe what is being tested and the expected outcome

   ```dart
   test('Should emit loading then success state on successful sign up', () { ... });
   ```

2. **Arrange-Act-Assert Pattern**:

   ```dart
   test('Description', () async {
     // Arrange - Set up test data and mocks
     final user = AuthFixtures.sampleAppUser;
     when(...).thenAnswer(...);

     // Act - Execute the code being tested
     final result = await useCase(...);

     // Assert - Verify the result
     expect(result, user);
     verify(...).called(1);
   });
   ```

3. **Comments for Non-Obvious Tests**:

   ```dart
   /// Test: Should successfully sign in user with valid credentials
   test('Should emit success state when credentials are valid', () { ... });
   ```

4. **Use Groups Wisely**:

   ```dart
   group('Feature Name', () {
     group('Validation Tests', () { ... });
     group('Success Cases', () { ... });
     group('Error Handling', () { ... });
   });
   ```

5. **One Assertion (When Possible)**:
   - Focus each test on one specific behavior
   - Use multiple related assertions only when testing state changes

### Template for New Test Files

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/[feature]/...';

import '../../../fixtures/[feature]_fixtures.dart';
import '../../../mocks/mocks.dart';

void main() {
  group('[Feature] [Component]', () {
    late Mock[Dependency] mock[Dependency];
    late [ClassBeingTested] classBeingTested;

    setUp(() {
      mock[Dependency] = Mock[Dependency]();
      classBeingTested = [ClassBeingTested](
        dependency: mock[Dependency],
      );
    });

    group('[Test Category]', () {
      /// Test: [Description of what is being tested]
      test('Should [expected behavior]', () async {
        // Arrange
        when(...).thenAnswer(...);

        // Act
        final result = await classBeingTested.method(...);

        // Assert
        expect(result, expectedValue);
      });
    });
  });
}
```

## 🔧 Key Testing Libraries

### Dependencies (in pubspec.yaml)

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0 # For mocking
  bloc_test: ^9.1.0 # For BLoC/Cubit testing
  flutter_lints: ^5.0.0 # For code quality
```

## ✅ Completed Test Coverage

### Auth Feature (100% Coverage)

- ✅ `WatchAuthenticatedUserUseCase`
- ✅ `SignUpWithEmailUseCase`
- ✅ `SignInWithEmailUseCase`
- ✅ `SignInWithGoogleUseCase`
- ✅ `SaveUserRoleUseCase`
- ✅ `SignOutUseCase`
- ✅ `AuthCubit` (all methods)
- ✅ `AuthRepositoryImpl`
- ✅ `AuthRemoteDataSource`

### Features Requiring Completion

- 📝 **Exam Feature**: Use template in `exam_cubit_test.dart`
- 📝 **Student Feature**: Use template in `student_cubit_test.dart`
- 📝 **Tutor Feature**: Use template in `tutor_cubit_test.dart`

## 🎓 Implementation Steps for New Tests

1. **Analyze the feature** - Understand the structure and dependencies
2. **Create fixtures** - Add test data factories to `fixtures/` folder
3. **Create mocks** - Add mock classes to `mocks/mocks.dart` (if not existing)
4. **Write domain tests** - Start with use cases
5. **Write data layer tests** - Test repositories and data sources
6. **Write Cubit tests** - Test state management
7. **Add widget tests** - Test UI components (advanced)

## 🐛 Troubleshooting

### Issue: Mocks not recognized

**Solution**: Import `mocks.dart` in your test file

```dart
import '../../../mocks/mocks.dart';
```

### Issue: Test times out

**Solution**: Increase timeout or check for infinite loops

```dart
test('Description', () async {
  // timeout increased to 10 seconds
}, timeout: Timeout(Duration(seconds: 10)));
```

### Issue: State comparison fails

**Solution**: Ensure `Equatable` is properly implemented

```dart
class MyState extends Equatable {
  @override
  List<Object?> get props => [field1, field2];
}
```

## 📚 Additional Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [BLoC Testing Guide](https://bloclibrary.dev/#/testing)
- [Mocktail Documentation](https://pub.dev/packages/mocktail)
- [Clean Architecture Testing](https://resocoder.com/flutter-clean-architecture)

## 👥 Contributing

When adding new tests:

1. Follow the established folder structure
2. Use meaningful test names
3. Add comments explaining complex test logic
4. Maintain consistency with existing patterns
5. Ensure all tests pass before committing

---

**Last Updated**: April 2026
**Test Framework**: Flutter Test + Bloc Test + Mocktail
