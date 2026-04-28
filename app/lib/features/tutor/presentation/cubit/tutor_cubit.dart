import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/request_status.dart';
import '../../domain/entities/exam_report.dart';
import '../../domain/entities/student_overview.dart';
import '../../domain/usecases/tutor_usecases.dart';
import 'tutor_state.dart';

class TutorCubit extends Cubit<TutorState> {
  TutorCubit({
    required WatchStudentsUseCase watchStudentsUseCase,
    required SetStudentLockUseCase setStudentLockUseCase,
    required StartExamForStudentsUseCase startExamForStudentsUseCase,
    required StopExamForStudentsUseCase stopExamForStudentsUseCase,
    required WatchExamReportsUseCase watchExamReportsUseCase,
  }) : _watchStudentsUseCase = watchStudentsUseCase,
       _setStudentLockUseCase = setStudentLockUseCase,
       _startExamForStudentsUseCase = startExamForStudentsUseCase,
       _stopExamForStudentsUseCase = stopExamForStudentsUseCase,
       _watchExamReportsUseCase = watchExamReportsUseCase,
       super(const TutorState());

  final WatchStudentsUseCase _watchStudentsUseCase;
  final SetStudentLockUseCase _setStudentLockUseCase;
  final StartExamForStudentsUseCase _startExamForStudentsUseCase;
  final StopExamForStudentsUseCase _stopExamForStudentsUseCase;
  final WatchExamReportsUseCase _watchExamReportsUseCase;

  StreamSubscription<List<StudentOverview>>? _studentsSubscription;
  StreamSubscription<List<ExamReport>>? _reportsSubscription;

  void startListening() {
    _studentsSubscription?.cancel();
    emit(state.copyWith(status: RequestStatus.loading, clearError: true));
    _studentsSubscription = _watchStudentsUseCase().listen(
      (students) {
        emit(
          state.copyWith(
            status: RequestStatus.success,
            students: students,
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

  Future<void> toggleStudentLock({
    required String studentId,
    required bool isLocked,
  }) async {
    try {
      await _setStudentLockUseCase(studentId: studentId, isLocked: isLocked);
      emit(
        state.copyWith(
          successMessage: isLocked ? 'student_locked' : 'student_unlocked',
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

  Future<void> startExam({
    required String examId,
    required String examTitle,
    required List<String> studentIds,
    required int durationMinutes,
  }) async {
    try {
      emit(
        state.copyWith(
          status: RequestStatus.loading,
          clearError: true,
          clearSuccess: true,
        ),
      );
      await _startExamForStudentsUseCase(
        examId: examId,
        examTitle: examTitle,
        studentIds: studentIds,
        durationMinutes: durationMinutes,
      );
      emit(
        state.copyWith(
          status: RequestStatus.success,
          successMessage: 'exam_started',
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

  Future<void> stopExam({
    required String examId,
    required List<String> studentIds,
  }) async {
    try {
      emit(
        state.copyWith(
          status: RequestStatus.loading,
          clearError: true,
          clearSuccess: true,
        ),
      );
      await _stopExamForStudentsUseCase(examId: examId, studentIds: studentIds);
      emit(
        state.copyWith(
          status: RequestStatus.success,
          successMessage: 'exam_stopped',
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

  void loadReports(String examId) {
    _reportsSubscription?.cancel();
    if (examId.isEmpty) {
      emit(state.copyWith(reports: const [], selectedReportExamId: null));
      return;
    }

    emit(
      state.copyWith(
        status: RequestStatus.loading,
        selectedReportExamId: examId,
        clearError: true,
      ),
    );
    _reportsSubscription = _watchExamReportsUseCase(examId).listen(
      (reports) {
        emit(
          state.copyWith(
            status: RequestStatus.success,
            reports: reports,
            selectedReportExamId: examId,
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

  @override
  Future<void> close() async {
    await _studentsSubscription?.cancel();
    await _reportsSubscription?.cancel();
    return super.close();
  }
}
