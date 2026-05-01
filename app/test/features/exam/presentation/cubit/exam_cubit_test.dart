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

  // ==================== Loading Exam Data Tests ====================
  group('Loading Exam Data', () {
    // ---------- watchExams ----------
    group('watchExams', () {
      /// Test: Should emit success state with exams when watch returns data
      blocTest<ExamCubit, ExamState>(
        'emits success state with exams when data is fetched successfully',
        setUp: () {
          when(() => mockWatchExamsUseCase())
              .thenAnswer((_) => Stream.value([sampleExam]));
        },
        build: () => examCubit,
        act: (cubit) => cubit.watchExams(),
        expect: () => [
          isA<ExamState>()
              .having(
                (state) => state.status,
                'status',
                RequestStatus.success,
              )
              .having(
                (state) => state.exams,
                'exams',
                [sampleExam],
              ),
        ],
      );

      /// Test: Should emit failure state when watch stream errors
      blocTest<ExamCubit, ExamState>(
        'emits failure state with error message when data fetch fails',
        setUp: () {
          when(() => mockWatchExamsUseCase())
              .thenAnswer((_) => Stream.error(Exception('Network error')));
        },
        build: () => examCubit,
        act: (cubit) => cubit.watchExams(),
        expect: () => [
          isA<ExamState>()
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

    // ---------- loadExamDetails ----------
    group('loadExamDetails', () {
      /// Test: Should emit loading then success with exam details
      blocTest<ExamCubit, ExamState>(
        'emits loading then success state when exam details loaded',
        setUp: () {
          when(() => mockLoadExamDetailsUseCase(testExamId))
              .thenAnswer((_) async => sampleExamDetails);
        },
        build: () => examCubit,
        act: (cubit) => cubit.loadExamDetails(testExamId),
        expect: () => [
          // Loading state
          isA<ExamState>().having(
            (state) => state.status,
            'status',
            RequestStatus.loading,
          ),
          // Success state with exam details
          isA<ExamState>()
              .having(
                (state) => state.status,
                'status',
                RequestStatus.success,
              )
              .having(
                (state) => state.examDetails,
                'examDetails',
                sampleExamDetails,
              ),
        ],
      );

      /// Test: Should emit loading then failure when load fails
      blocTest<ExamCubit, ExamState>(
        'emits loading then failure state when exam details fetch fails',
        setUp: () {
          when(() => mockLoadExamDetailsUseCase(testExamId))
              .thenThrow(Exception('Exam not found'));
        },
        build: () => examCubit,
        act: (cubit) => cubit.loadExamDetails(testExamId),
        expect: () => [
          isA<ExamState>().having(
            (state) => state.status,
            'status',
            RequestStatus.loading,
          ),
          isA<ExamState>()
              .having(
                (state) => state.status,
                'status',
                RequestStatus.failure,
              )
              .having(
                (state) => state.errorMessage,
                'errorMessage',
                contains('Exam not found'),
              ),
        ],
      );
    });
  });

  // ==================== Exam Submission and Results Tests ====================
  group('Exam Submission and Results', () {
    // ---------- submitAnswers ----------
    group('submitAnswers', () {
      /// Test: Should emit loading then success with hasSubmitted=true on success
      blocTest<ExamCubit, ExamState>(
        'emits submitting then success state when submission is successful',
        seed: () => ExamState(
          status: RequestStatus.success,
          examDetails: sampleExamDetails,
          selectedAnswers: const {'q-1': 1},
        ),
        setUp: () {
          when(
            () => mockSubmitExamAnswersUseCase(
              studentId: any(named: 'studentId'),
              studentName: any(named: 'studentName'),
              examId: any(named: 'examId'),
              answers: any(named: 'answers'),
            ),
          ).thenAnswer((_) async => {});
        },
        build: () => examCubit,
        act: (cubit) => cubit.submitAnswers(
          studentId: testStudentId,
          studentName: testStudentName,
          autoSubmitted: false,
        ),
        expect: () => [
          // Loading state
          isA<ExamState>().having(
            (state) => state.status,
            'status',
            RequestStatus.loading,
          ),
          // Success state with hasSubmitted true
          isA<ExamState>()
              .having(
                (state) => state.status,
                'status',
                RequestStatus.success,
              )
              .having(
                (state) => state.hasSubmitted,
                'hasSubmitted',
                true,
              )
              .having(
                (state) => state.successMessage,
                'successMessage',
                'answers_submitted',
              ),
        ],
      );

      /// Test: Should emit failure state when submission fails
      blocTest<ExamCubit, ExamState>(
        'emits submitting then error state when submission fails',
        seed: () => ExamState(
          status: RequestStatus.success,
          examDetails: sampleExamDetails,
          selectedAnswers: const {'q-1': 1},
        ),
        setUp: () {
          when(
            () => mockSubmitExamAnswersUseCase(
              studentId: any(named: 'studentId'),
              studentName: any(named: 'studentName'),
              examId: any(named: 'examId'),
              answers: any(named: 'answers'),
            ),
          ).thenThrow(Exception('Submission failed'));
        },
        build: () => examCubit,
        act: (cubit) => cubit.submitAnswers(
          studentId: testStudentId,
          studentName: testStudentName,
          autoSubmitted: false,
        ),
        expect: () => [
          isA<ExamState>().having(
            (state) => state.status,
            'status',
            RequestStatus.loading,
          ),
          isA<ExamState>()
              .having(
                (state) => state.status,
                'status',
                RequestStatus.failure,
              )
              .having(
                (state) => state.errorMessage,
                'errorMessage',
                contains('Submission failed'),
              ),
        ],
      );

      /// Test: Should not submit if already submitted
      blocTest<ExamCubit, ExamState>(
        'does not re-submit if already submitted',
        seed: () => ExamState(
          status: RequestStatus.success,
          examDetails: sampleExamDetails,
          hasSubmitted: true,
        ),
        build: () => examCubit,
        act: (cubit) => cubit.submitAnswers(
          studentId: testStudentId,
          studentName: testStudentName,
          autoSubmitted: false,
        ),
        expect: () => [],
        verify: (_) {
          verifyNever(
            () => mockSubmitExamAnswersUseCase(
              studentId: any(named: 'studentId'),
              studentName: any(named: 'studentName'),
              examId: any(named: 'examId'),
              answers: any(named: 'answers'),
            ),
          );
        },
      );

      /// Test: Should set auto_submitted message when auto-submitted
      blocTest<ExamCubit, ExamState>(
        'emits auto_submitted success message when auto-submitted by timer',
        seed: () => ExamState(
          status: RequestStatus.success,
          examDetails: sampleExamDetails,
          selectedAnswers: const {'q-1': 0},
        ),
        setUp: () {
          when(
            () => mockSubmitExamAnswersUseCase(
              studentId: any(named: 'studentId'),
              studentName: any(named: 'studentName'),
              examId: any(named: 'examId'),
              answers: any(named: 'answers'),
            ),
          ).thenAnswer((_) async => {});
        },
        build: () => examCubit,
        act: (cubit) => cubit.submitAnswers(
          studentId: testStudentId,
          studentName: testStudentName,
          autoSubmitted: true,
        ),
        expect: () => [
          isA<ExamState>().having(
            (state) => state.status,
            'status',
            RequestStatus.loading,
          ),
          isA<ExamState>()
              .having(
                (state) => state.hasSubmitted,
                'hasSubmitted',
                true,
              )
              .having(
                (state) => state.successMessage,
                'successMessage',
                'auto_submitted',
              ),
        ],
      );
    });

    // ---------- selectAnswer ----------
    group('selectAnswer', () {
      /// Test: Should update selectedAnswers map correctly
      test('updates selected answers map with chosen answer', () {
        examCubit.selectAnswer(questionId: 'q-1', answerIndex: 2);
        expect(examCubit.state.selectedAnswers, {'q-1': 2});
      });

      /// Test: Should override previous selection for same question
      test('overrides previous answer for the same question', () {
        examCubit.selectAnswer(questionId: 'q-1', answerIndex: 0);
        examCubit.selectAnswer(questionId: 'q-1', answerIndex: 3);
        expect(examCubit.state.selectedAnswers, {'q-1': 3});
      });

      /// Test: Should handle multiple questions independently
      test('handles multiple question selections independently', () {
        examCubit.selectAnswer(questionId: 'q-1', answerIndex: 1);
        examCubit.selectAnswer(questionId: 'q-2', answerIndex: 0);
        expect(examCubit.state.selectedAnswers, {'q-1': 1, 'q-2': 0});
      });
    });
  });
}
