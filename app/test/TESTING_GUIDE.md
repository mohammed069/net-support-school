# Testing Implementation Guide

This guide provides step-by-step instructions for completing the remaining tests in the test suite.

## 📋 Quick Start Checklist

- [x] **Core Setup**
  - [x] pubspec.yaml updated with test dependencies
  - [x] test/ folder structure created
  - [x] Mocks defined in `test/mocks/mocks.dart`
  - [x] Fixtures created in `test/fixtures/`

- [x] **Auth Feature Tests** (✅ Complete)
  - [x] Use cases tests
  - [x] Cubit tests
  - [x] Repository tests
  - [x] Data source tests

- [ ] **Exam Feature Tests** (🔧 In Progress)
  - [ ] Create exam fixtures
  - [ ] Write use cases tests
  - [ ] Write Cubit tests
  - [ ] Write repository tests
  - [ ] Write data source tests

- [ ] **Student Feature Tests** (🔧 In Progress)
  - [ ] Create student fixtures
  - [ ] Write use cases tests
  - [ ] Write Cubit tests
  - [ ] Write repository tests
  - [ ] Write data source tests

- [ ] **Tutor Feature Tests** (🔧 In Progress)
  - [ ] Create tutor fixtures
  - [ ] Write use cases tests
  - [ ] Write Cubit tests
  - [ ] Write repository tests
  - [ ] Write data source tests

## 🔍 How to Implement Tests for a New Feature

### Step 1: Analyze the Feature Structure

Before writing tests, understand the feature's architecture:

```bash
# Example: Exam Feature
lib/features/exam/
├── domain/
│   ├── entities/          # Business objects
│   ├── repositories/      # Abstract repository
│   └── usecases/          # Business logic
├── data/
│   ├── datasources/       # API/Firebase calls
│   ├── models/            # Data models
│   └── repositories/      # Repository implementation
└── presentation/
    ├── cubit/             # State management
    ├── pages/             # Screens
    └── widgets/           # Components
```

### Step 2: Create Test Fixtures

Create a file like `test/fixtures/exam_fixtures.dart`:

```dart
import 'package:app/features/exam/domain/entities/exam.dart';
import 'package:app/features/exam/data/models/exam_model.dart';

class ExamFixtures {
  // Test data constants
  static const testExamId = 'exam-123';
  static const testExamTitle = 'Math Midterm';

  // Sample entities
  static Exam get sampleExam {
    return const Exam(
      id: testExamId,
      title: testExamTitle,
      description: 'Test Description',
      durationMinutes: 60,
      // ... other properties
    );
  }

  // Sample models
  static ExamModel get sampleExamModel {
    return ExamModel(
      id: testExamId,
      title: testExamTitle,
      // ... other properties
    );
  }
}
```

### Step 3: Add Mock Classes (if not existing)

Update `test/mocks/mocks.dart`:

```dart
import 'package:app/features/exam/domain/repositories/exam_repository.dart';
import 'package:app/features/exam/domain/usecases/exam_usecases.dart';

// Add these mock classes
class MockExamRepository extends Mock implements ExamRepository {}
class MockWatchExamsUseCase extends Mock implements WatchExamsUseCase {}
class MockCreateExamUseCase extends Mock implements CreateExamUseCase {}
// ... add all exam-related use case mocks
```

### Step 4: Write Use Case Tests

Create `test/features/exam/domain/usecases/exam_usecases_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/exam/domain/repositories/exam_repository.dart';
import 'package:app/features/exam/domain/usecases/exam_usecases.dart';

import '../../../../fixtures/exam_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  group('Exam UseCases', () {
    // ==================== WatchExamsUseCase ====================
    group('WatchExamsUseCase', () {
      late MockExamRepository mockExamRepository;
      late WatchExamsUseCase useCase;

      setUp(() {
        mockExamRepository = MockExamRepository();
        useCase = WatchExamsUseCase(mockExamRepository);
      });

      /// Test: Should return stream of exams
      test(
        'Should emit exams when repository returns stream',
        () {
          // Arrange
          final testExam = ExamFixtures.sampleExam;
          when(() => mockExamRepository.watchExams())
              .thenAnswer((_) => Stream.value([testExam]));

          // Act
          final result = useCase();

          // Assert
          expect(result, emits([testExam]));
        },
      );

      // ✏️ Add more test cases for error scenarios
    });

    // ==================== CreateExamUseCase ====================
    group('CreateExamUseCase', () {
      // ✏️ Follow the pattern from auth_usecases_test.dart
      // - Test successful creation
      // - Test error handling
      // - Test parameter validation
    });

    // ✏️ Add test groups for other use cases
  });
}
```

### Step 5: Write Cubit/BLoC Tests

Create `test/features/exam/presentation/cubit/exam_cubit_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/exam/presentation/cubit/exam_cubit.dart';

import '../../../../fixtures/exam_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  group('ExamCubit', () {
    late MockWatchExamsUseCase mockWatchExamsUseCase;
    late MockCreateExamUseCase mockCreateExamUseCase;
    late ExamCubit examCubit;

    setUp(() {
      mockWatchExamsUseCase = MockWatchExamsUseCase();
      mockCreateExamUseCase = MockCreateExamUseCase();

      examCubit = ExamCubit(
        watchExamsUseCase: mockWatchExamsUseCase,
        createExamUseCase: mockCreateExamUseCase,
        // ... add other dependencies
      );
    });

    tearDown(() async {
      await examCubit.close();
    });

    group('watchExams', () {
      /// Test: Should emit exams on success
      blocTest<ExamCubit, ExamState>(
        'Should emit exams when watch succeeds',
        setUp: () {
          when(() => mockWatchExamsUseCase())
              .thenAnswer((_) => Stream.value([ExamFixtures.sampleExam]));
        },
        build: () => examCubit,
        act: (cubit) => cubit.watchExams(),
        expect: () => [
          // Expected state emissions
          // Example:
          // ExamState(status: RequestStatus.success, exams: [sampleExam]),
        ],
      );

      // ✏️ Add error handling test
    });

    group('createExam', () {
      // ✏️ Follow pattern from auth_cubit_test.dart signUpWithEmail
      // - Test loading state
      // - Test success state
      // - Test failure state
    });

    // ✏️ Add test groups for other Cubit methods
  });
}
```

### Step 6: Write Repository Tests

Create `test/features/exam/data/repositories/exam_repository_impl_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/exam/data/repositories/exam_repository_impl.dart';

import '../../../../fixtures/exam_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  group('ExamRepositoryImpl', () {
    late MockExamRemoteDataSource mockExamRemoteDataSource;
    late ExamRepositoryImpl examRepositoryImpl;

    setUp(() {
      mockExamRemoteDataSource = MockExamRemoteDataSource();
      examRepositoryImpl = ExamRepositoryImpl(
        remoteDataSource: mockExamRemoteDataSource,
      );
    });

    group('watchExams', () {
      /// Test: Should return stream of exams
      test(
        'Should return stream from datasource',
        () {
          // Arrange
          final testExam = ExamFixtures.sampleExam;
          when(() => mockExamRemoteDataSource.watchExams())
              .thenAnswer((_) => Stream.value([testExam]));

          // Act
          final result = examRepositoryImpl.watchExams();

          // Assert
          expect(result, emits([testExam]));
          verify(() => mockExamRemoteDataSource.watchExams()).called(1);
        },
      );

      // ✏️ Add error handling test
    });

    group('createExam', () {
      // ✏️ Follow pattern from auth_repository_impl_test.dart
      // - Test successful creation
      // - Test error propagation
    });

    // ✏️ Add test groups for other methods
  });
}
```

### Step 7: Write Data Source Tests

Create `test/features/exam/data/datasources/exam_remote_data_source_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app/features/exam/data/datasources/exam_remote_data_source.dart';

import '../../../../fixtures/exam_fixtures.dart';
import '../../../../mocks/mocks.dart';

void main() {
  group('ExamRemoteDataSource', () {
    late MockFirebaseFirestore mockFirebaseFirestore;
    late ExamRemoteDataSource examRemoteDataSource;

    setUp(() {
      mockFirebaseFirestore = MockFirebaseFirestore();
      examRemoteDataSource = ExamRemoteDataSource(
        firestore: mockFirebaseFirestore,
      );
    });

    group('watchExams', () {
      /// Test: Should return stream of exams from Firestore
      test(
        'Should return stream from Firestore collection',
        () {
          // Arrange
          final mockCollectionRef = MockCollectionReference();
          final mockQuerySnapshot = MockQuerySnapshot();

          when(() => mockFirebaseFirestore.collection('exams'))
              .thenReturn(mockCollectionRef);
          when(() => mockCollectionRef.snapshots())
              .thenAnswer((_) => Stream.value(mockQuerySnapshot));
          when(() => mockQuerySnapshot.docs).thenReturn([]);

          // Act
          final result = examRemoteDataSource.watchExams();

          // Assert
          expect(result, emits(isA<List>()));
        },
      );

      // ✏️ Add error handling test
    });

    group('createExam', () {
      // ✏️ Follow pattern from auth_remote_data_source_test.dart
      // - Test Firestore write
      // - Test error handling
      // - Test data transformation
    });

    // ✏️ Add test groups for other methods
  });
}
```

## 🎯 Common Patterns to Follow

### Pattern 1: Testing Use Cases

```dart
test('Should return/emit expected result', () async {
  // Arrange
  when(() => mockRepository.method(...))
      .thenAnswer((_) => expectedResult);

  // Act
  final result = await useCase(...);

  // Assert
  expect(result, expectedResult);
  verify(() => mockRepository.method(...)).called(1);
});
```

### Pattern 2: Testing Cubits (Success Flow)

```dart
blocTest<MyCubit, MyState>(
  'Should emit loading then success',
  setUp: () {
    when(() => mockUseCase(...))
        .thenAnswer((_) async => expectedData);
  },
  build: () => myCubit,
  act: (cubit) => cubit.method(...),
  expect: () => [
    MyState(status: RequestStatus.loading),
    MyState(status: RequestStatus.success, data: expectedData),
  ],
);
```

### Pattern 3: Testing Cubits (Error Flow)

```dart
blocTest<MyCubit, MyState>(
  'Should emit loading then failure',
  setUp: () {
    when(() => mockUseCase(...))
        .thenThrow(Exception('Error'));
  },
  build: () => myCubit,
  act: (cubit) => cubit.method(...),
  expect: () => [
    MyState(status: RequestStatus.loading),
    MyState(status: RequestStatus.failure, errorMessage: contains('Error')),
  ],
);
```

### Pattern 4: Testing Repositories

```dart
test('Should call datasource and return result', () async {
  // Arrange
  when(() => mockDataSource.method(...))
      .thenAnswer((_) async => testModel);

  // Act
  final result = await repository.method(...);

  // Assert
  expect(result, testModel);
  verify(() => mockDataSource.method(...)).called(1);
});
```

## ✅ Verification Checklist

Before committing new tests, verify:

- [ ] All tests have descriptive names
- [ ] Each test group has a clear purpose
- [ ] Comments explain non-obvious test logic
- [ ] Mocks are properly set up and torn down
- [ ] Test fixtures are used consistently
- [ ] Error scenarios are tested
- [ ] Happy paths are tested
- [ ] Edge cases are considered
- [ ] Code follows the established patterns
- [ ] All tests pass (`flutter test`)

## 🔧 Running Your New Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/exam/...

# Run with coverage
flutter test --coverage

# Watch mode during development
flutter test --watch
```

## 📞 Need Help?

Refer to:

1. **Existing Tests**: Check `auth_*_test.dart` files for patterns
2. **README.md**: General testing guidelines
3. **Fixtures**: Use test data from `exam_fixtures.dart`
4. **Mocks**: Reference mock classes in `test/mocks/mocks.dart`

---

**Happy Testing! 🚀**
