import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/core/enums/request_status.dart';
import 'package:app/features/exam/presentation/cubit/exam_cubit.dart';
import 'package:app/features/exam/presentation/cubit/exam_state.dart';
import 'package:app/features/exam/domain/entities/exam.dart';
import 'package:app/features/exam/domain/entities/exam_details.dart';
import 'package:app/features/exam/domain/entities/exam_question.dart';
import 'package:app/features/exam/domain/usecases/exam_usecases.dart';
import 'package:app/features/student/domain/usecases/student_usecases.dart';

// ==================== Mock Classes ====================
class MockWatchExamsUseCase extends Mock implements WatchExamsUseCase {}

class MockCreateExamUseCase extends Mock implements CreateExamUseCase {}

class MockAddQuestionUseCase extends Mock implements AddQuestionUseCase {}

class MockLoadExamDetailsUseCase extends Mock
    implements LoadExamDetailsUseCase {}

class MockMarkExamStartedUseCase extends Mock
    implements MarkExamStartedUseCase {}

class MockSubmitExamAnswersUseCase extends Mock
    implements SubmitExamAnswersUseCase {}

// ==================== Test Data ====================
const testExamId = 'exam-123';
const testStudentId = 'student-456';
const testStudentName = 'Test Student';

final sampleExam = Exam(
  id: testExamId,
  title: 'Math Midterm',
  description: 'A test exam',
  durationMinutes: 60,
  createdBy: 'tutor-789',
  isActive: true,
);

const sampleQuestion = ExamQuestion(
  id: 'q-1',
  question: 'What is 2 + 2?',
  options: ['3', '4', '5', '6'],
  correctAnswerIndex: 1,
  order: 0,
);

final sampleExamDetails = ExamDetails(
  exam: sampleExam,
  questions: [sampleQuestion],
);

void main() {
  // ==================== Variable Declarations ====================
  late MockWatchExamsUseCase mockWatchExamsUseCase;
  late MockCreateExamUseCase mockCreateExamUseCase;
  late MockAddQuestionUseCase mockAddQuestionUseCase;
  late MockLoadExamDetailsUseCase mockLoadExamDetailsUseCase;
  late MockMarkExamStartedUseCase mockMarkExamStartedUseCase;
  late MockSubmitExamAnswersUseCase mockSubmitExamAnswersUseCase;
  late ExamCubit examCubit;

  // ==================== Setup & Teardown ====================
  setUp(() {
    mockWatchExamsUseCase = MockWatchExamsUseCase();
    mockCreateExamUseCase = MockCreateExamUseCase();
    mockAddQuestionUseCase = MockAddQuestionUseCase();
    mockLoadExamDetailsUseCase = MockLoadExamDetailsUseCase();
    mockMarkExamStartedUseCase = MockMarkExamStartedUseCase();
    mockSubmitExamAnswersUseCase = MockSubmitExamAnswersUseCase();

    examCubit = ExamCubit(
      watchExamsUseCase: mockWatchExamsUseCase,
      createExamUseCase: mockCreateExamUseCase,
      addQuestionUseCase: mockAddQuestionUseCase,
      loadExamDetailsUseCase: mockLoadExamDetailsUseCase,
      markExamStartedUseCase: mockMarkExamStartedUseCase,
      submitExamAnswersUseCase: mockSubmitExamAnswersUseCase,
    );
  });

  tearDown(() async {
    await examCubit.close();
  });

  // ==================== Initial State ====================
  group('ExamCubit Setup', () {
    test('initial state should be ExamState with initial status', () {
      expect(
        examCubit.state,
        const ExamState(status: RequestStatus.initial),
      );
    });

    test('all mock dependencies are initialized correctly', () {
      expect(mockWatchExamsUseCase, isNotNull);
      expect(mockCreateExamUseCase, isNotNull);
      expect(mockAddQuestionUseCase, isNotNull);
      expect(mockLoadExamDetailsUseCase, isNotNull);
      expect(mockMarkExamStartedUseCase, isNotNull);
      expect(mockSubmitExamAnswersUseCase, isNotNull);
    });
  });
}
