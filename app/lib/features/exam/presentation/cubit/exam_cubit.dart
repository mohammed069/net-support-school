import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/request_status.dart';
import '../../../student/domain/usecases/student_usecases.dart';
import '../../domain/entities/exam.dart';
import '../../domain/entities/exam_question.dart';
import '../../domain/usecases/exam_usecases.dart';
import 'exam_state.dart';

class ExamCubit extends Cubit<ExamState> {
  ExamCubit({
    required WatchExamsUseCase watchExamsUseCase,
    required CreateExamUseCase createExamUseCase,
    required AddQuestionUseCase addQuestionUseCase,
    required LoadExamDetailsUseCase loadExamDetailsUseCase,
    required MarkExamStartedUseCase markExamStartedUseCase,
    required SubmitExamAnswersUseCase submitExamAnswersUseCase,
  }) : _watchExamsUseCase = watchExamsUseCase,
       _createExamUseCase = createExamUseCase,
       _addQuestionUseCase = addQuestionUseCase,
       _loadExamDetailsUseCase = loadExamDetailsUseCase,
       _markExamStartedUseCase = markExamStartedUseCase,
       _submitExamAnswersUseCase = submitExamAnswersUseCase,
       super(const ExamState());

  final WatchExamsUseCase _watchExamsUseCase;
  final CreateExamUseCase _createExamUseCase;
  final AddQuestionUseCase _addQuestionUseCase;
  final LoadExamDetailsUseCase _loadExamDetailsUseCase;
  final MarkExamStartedUseCase _markExamStartedUseCase;
  final SubmitExamAnswersUseCase _submitExamAnswersUseCase;

  StreamSubscription<List<Exam>>? _examsSubscription;
  Timer? _countdownTimer;

  void watchExams() {
    _examsSubscription?.cancel();
    _examsSubscription = _watchExamsUseCase().listen(
      (exams) {
        emit(
          state.copyWith(
            status: RequestStatus.success,
            exams: exams,
            clearError: true,
          ),
        );
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: RequestStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> createExam({
    required String title,
    required String description,
    required int durationMinutes,
    required String createdBy,
    String? initialQuestion,
    List<String>? initialOptions,
    int? initialCorrectAnswerIndex,
  }) async {
    try {
      emit(
        state.copyWith(
          status: RequestStatus.loading,
          clearError: true,
          clearSuccess: true,
        ),
      );
      final exam = await _createExamUseCase(
        title: title,
        description: description,
        durationMinutes: durationMinutes,
        createdBy: createdBy,
      );

      if (initialQuestion != null &&
          initialOptions != null &&
          initialCorrectAnswerIndex != null) {
        await _addQuestionUseCase(
          examId: exam.id,
          question: ExamQuestion(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            question: initialQuestion,
            options: initialOptions,
            correctAnswerIndex: initialCorrectAnswerIndex,
            order: 0,
          ),
        );
      }

      await loadExamDetails(exam.id);
      emit(
        state.copyWith(
          status: RequestStatus.success,
          successMessage: 'exam_created',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> addQuestion({
    required String examId,
    required String question,
    required List<String> options,
    required int correctAnswerIndex,
  }) async {
    try {
      emit(
        state.copyWith(
          status: RequestStatus.loading,
          clearError: true,
          clearSuccess: true,
        ),
      );
      final nextOrder = state.examDetails?.questions.length ?? 0;
      await _addQuestionUseCase(
        examId: examId,
        question: ExamQuestion(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          question: question,
          options: options,
          correctAnswerIndex: correctAnswerIndex,
          order: nextOrder,
        ),
      );
      await loadExamDetails(examId);
      emit(
        state.copyWith(
          status: RequestStatus.success,
          successMessage: 'question_added',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> loadExamDetails(String examId) async {
    try {
      emit(
        state.copyWith(
          status: RequestStatus.loading,
          clearError: true,
          clearSuccess: true,
        ),
      );
      final examDetails = await _loadExamDetailsUseCase(examId);
      emit(
        state.copyWith(
          status: RequestStatus.success,
          examDetails: examDetails,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> initializeExam({
    required String examId,
    required int durationMinutes,
    required String studentId,
    required String studentName,
  }) async {
    if (examId.isEmpty) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          errorMessage: 'No exam id provided.',
        ),
      );
      return;
    }

    await _markExamStartedUseCase(studentId);
    await loadExamDetails(examId);
    emit(
      state.copyWith(
        remainingSeconds: durationMinutes * 60,
        selectedAnswers: const {},
        hasSubmitted: false,
        successMessage: 'exam_ready',
      ),
    );
    _startTimer(studentId: studentId, studentName: studentName);
  }

  void selectAnswer({required String questionId, required int answerIndex}) {
    final updatedAnswers = Map<String, int>.from(state.selectedAnswers)
      ..[questionId] = answerIndex;
    emit(state.copyWith(selectedAnswers: updatedAnswers));
  }

  Future<void> submitAnswers({
    required String studentId,
    required String studentName,
    required bool autoSubmitted,
  }) async {
    final examId = state.examDetails?.exam.id;
    if (examId == null || state.hasSubmitted) {
      return;
    }

    try {
      _countdownTimer?.cancel();
      emit(
        state.copyWith(
          status: RequestStatus.loading,
          clearError: true,
          clearSuccess: true,
        ),
      );
      await _submitExamAnswersUseCase(
        studentId: studentId,
        studentName: studentName,
        examId: examId,
        answers: state.selectedAnswers,
      );
      emit(
        state.copyWith(
          status: RequestStatus.success,
          hasSubmitted: true,
          successMessage:
              autoSubmitted ? 'auto_submitted' : 'answers_submitted',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _startTimer({required String studentId, required String studentName}) {
    _countdownTimer?.cancel();
    if (state.remainingSeconds <= 0) {
      return;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (state.remainingSeconds <= 1) {
        timer.cancel();
        emit(state.copyWith(remainingSeconds: 0));
        await submitAnswers(
          studentId: studentId,
          studentName: studentName,
          autoSubmitted: true,
        );
        return;
      }

      emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
    });
  }

  @override
  Future<void> close() async {
    await _examsSubscription?.cancel();
    _countdownTimer?.cancel();
    return super.close();
  }
}
