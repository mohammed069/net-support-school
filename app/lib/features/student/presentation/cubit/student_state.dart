import 'package:equatable/equatable.dart';

import '../../../../core/enums/request_status.dart';
import '../../domain/entities/student_session.dart';

class StudentState extends Equatable {
  const StudentState({
    this.status = RequestStatus.initial,
    this.session,
    this.errorMessage,
  });

  final RequestStatus status;
  final StudentSession? session;
  final String? errorMessage;

  StudentState copyWith({
    RequestStatus? status,
    StudentSession? session,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StudentState(
      status: status ?? this.status,
      session: session ?? this.session,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, session, errorMessage];
}
