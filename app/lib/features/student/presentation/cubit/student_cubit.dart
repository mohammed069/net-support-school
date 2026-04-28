import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/request_status.dart';
import '../../domain/entities/student_session.dart';
import '../../domain/usecases/student_usecases.dart';
import 'student_state.dart';

class StudentCubit extends Cubit<StudentState> {
  StudentCubit({required WatchStudentSessionUseCase watchStudentSessionUseCase})
    : _watchStudentSessionUseCase = watchStudentSessionUseCase,
      super(const StudentState());

  final WatchStudentSessionUseCase _watchStudentSessionUseCase;
  StreamSubscription<StudentSession?>? _sessionSubscription;

  void startListening(String studentId) {
    _sessionSubscription?.cancel();
    emit(state.copyWith(status: RequestStatus.loading, clearError: true));
    _sessionSubscription = _watchStudentSessionUseCase(studentId).listen(
      (session) {
        emit(
          state.copyWith(
            status: RequestStatus.success,
            session: session,
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
    await _sessionSubscription?.cancel();
    return super.close();
  }
}
