# Testing Quick Reference

A quick guide for developers writing tests for the Net Support School app.

## 🚀 Quick Start

```bash
# Run all tests
flutter test

# Run with coverage report
flutter test --coverage

# Watch mode (re-run on changes)
flutter test --watch

# Run specific test
flutter test test/features/auth/...
```

## 📝 Test File Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/features/[feature]/...';

import '../../../fixtures/[feature]_fixtures.dart';
import '../../../mocks/mocks.dart';

void main() {
  group('[Feature/Component Name]', () {
    late Mock[Dependency] mock[Dependency];
    late [ClassUnderTest] classUnderTest;

    setUp(() {
      mock[Dependency] = Mock[Dependency]();
      classUnderTest = [ClassUnderTest](
        dependency: mock[Dependency],
      );
    });

    group('[SubFeature/Method Name]', () {
      /// Test: [What is being tested]
      test('Should [expected behavior]', () async {
        // Arrange
        when(...).thenAnswer(...);

        // Act
        final result = await classUnderTest.method(...);

        // Assert
        expect(result, expectedValue);
      });
    });
  });
}
```

## 🎯 Common Test Patterns

### Unit Test (Use Cases, Business Logic)

```dart
test('Should return correct result', () async {
  // Arrange
  when(() => mockRepo.getData()).thenAnswer((_) async => testData);

  // Act
  final result = await useCase();

  // Assert
  expect(result, testData);
  verify(() => mockRepo.getData()).called(1);
});
```

### BLoC/Cubit Test

```dart
blocTest<MyCubit, MyState>(
  'Should emit loading then success',
  setUp: () {
    when(() => mockUseCase()).thenAnswer((_) async => data);
  },
  build: () => cubit,
  act: (cubit) => cubit.doSomething(),
  expect: () => [
    MyState(status: RequestStatus.loading),
    MyState(status: RequestStatus.success, data: data),
  ],
);
```

### Repository Test

```dart
test('Should call datasource and return result', () async {
  // Arrange
  when(() => mockDataSource.getData())
      .thenAnswer((_) async => model);

  // Act
  final result = await repository.getData();

  // Assert
  expect(result, model);
  verify(() => mockDataSource.getData()).called(1);
});
```

### Widget Test

```dart
testWidgets('Should display button', (tester) async {
  // Arrange & Act
  await tester.pumpWidget(MyApp());

  // Assert
  expect(find.text('Click Me'), findsOneWidget);

  // Act - Tap button
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();

  // Assert - Verify result
  expect(find.text('Success'), findsOneWidget);
});
```

## 🔍 Useful `find` Methods

```dart
// By Widget Type
find.byType(TextField)
find.byType(ElevatedButton)

// By Text
find.text('Click Me')

// By Key
find.byKey(ValueKey('myKey'))

// By Semantics Label
find.bySemanticsLabel('Tap to submit')

// Combinations
find.byType(Button).first
find.byType(Button).last
find.byType(Button).at(2)
```

## ✔️ Useful `expect` Matchers

```dart
// Widget Finders
expect(find.text('Hello'), findsOneWidget);        // Exactly 1
expect(find.text('Hello'), findsWidgets);         // 1 or more
expect(find.text('Hello'), findsNothing);         // 0 widgets

// Values
expect(result, equals(expected));
expect(result, isNotNull);
expect(result, isNull);
expect(result, isA<Type>());

// Collections
expect(list, contains(item));
expect(list, hasLength(3));
expect(list, isEmpty);
expect(list, isNotEmpty);

// Strings
expect(text, contains('substring'));
expect(text, startsWith('prefix'));
expect(text, endsWith('suffix'));

// Errors
expect(() => function(), throwsException);
expect(() => function(), throwsA(isA<CustomException>()));
```

## 🧩 Mocking Patterns

### Setup Mock to Return Value

```dart
when(() => mock.method()).thenAnswer((_) => value);
```

### Setup Mock to Throw Error

```dart
when(() => mock.method()).thenThrow(Exception('Error'));
```

### Verify Mock Was Called

```dart
verify(() => mock.method()).called(1);          // Called once
verify(() => mock.method()).called(greaterThan(0)); // Called at least once
verifyNever(() => mock.method());               // Never called
```

### Setup Multiple Calls

```dart
when(() => mock.method())
    .thenAnswer((_) => firstValue)
    .thenAnswer((_) => secondValue);
```

## 📦 Test Fixtures Usage

```dart
// Instead of creating test data in every test:
final user = AuthFixtures.sampleAppUser;
final email = AuthFixtures.testEmail;
final password = AuthFixtures.testPassword;
```

## 🛠️ Async Testing

```dart
// Waiting for async operations
await Future.delayed(Duration(milliseconds: 100));

// In Cubit tests - Wait for state transitions
await tester.pumpAndSettle();

// With custom timeout
await tester.pumpAndSettle(Duration(seconds: 5));

// In widget tests - Tap and settle
await tester.tap(find.byType(Button));
await tester.pumpAndSettle();
```

## 🐛 Common Mistakes & Fixes

### Mistake: Forgot to await async function

```dart
// ❌ Wrong
result = useCase.getData(); // Missing await

// ✅ Correct
result = await useCase.getData();
```

### Mistake: Mock not registered in group

```dart
// ❌ Wrong
group('Tests', () {
  // mock created in test, not setUp
  test('...', () {
    MockRepo mockRepo = MockRepo();
  });
});

// ✅ Correct
group('Tests', () {
  late MockRepo mockRepo;

  setUp(() {
    mockRepo = MockRepo();
  });

  test('...', () { /* use mockRepo */ });
});
```

### Mistake: forget to close Cubit/Stream

```dart
// ❌ Wrong
tearDown(() {
  // forgot to close cubit
});

// ✅ Correct
tearDown(() async {
  await cubit.close();
});
```

### Mistake: Not using pumpAndSettle

```dart
// ❌ Wrong - Animation might not complete
await tester.tap(find.byType(Button));
expect(find.text('New Text'), findsOneWidget);

// ✅ Correct - Wait for animations
await tester.tap(find.byType(Button));
await tester.pumpAndSettle();
expect(find.text('New Text'), findsOneWidget);
```

## 📚 File Organization

```
test/
├── fixtures/
│   ├── auth_fixtures.dart          ← Test data for auth
│   ├── exam_fixtures.dart          ← Test data for exam
│   └── common_fixtures.dart        ← Common test data
├── mocks/
│   └── mocks.dart                  ← All mock classes
└── features/
    ├── auth/
    │   ├── domain/usecases/
    │   ├── data/
    │   │   ├── datasources/
    │   │   └── repositories/
    │   └── presentation/cubit/
    └── [other features]/
```

## 💡 Tips & Tricks

### Tip 1: Use Fixtures for Consistency

```dart
// Bad - Scattered test data
final user = AppUser(...); // In one test

// Good - Centralized
final user = AuthFixtures.sampleAppUser;
```

### Tip 2: Use Descriptive Test Names

```dart
// Bad
test('test login', () { ... });

// Good
test('Should emit success state when email and password are valid', () { ... });
```

### Tip 3: Group Related Tests

```dart
group('AuthCubit', () {
  group('signInWithEmail', () {
    test('Should succeed with valid credentials', () { ... });
    test('Should fail with invalid credentials', () { ... });
  });
});
```

### Tip 4: Add Comments to Complex Tests

```dart
/// Test: Ensures the stream properly handles subscription cancellation
test('Should cancel subscriptions on listener cancel', () async {
  // Implementation...
});
```

## 🔗 Resources

- [Flutter Testing Docs](https://flutter.dev/docs/testing)
- [Bloc Test Docs](https://bloclibrary.dev/#/testing)
- [Mocktail Docs](https://pub.dev/packages/mocktail)

---

**Need more help? Check test/README.md or test/TESTING_GUIDE.md**
