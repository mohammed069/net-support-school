import 'package:equatable/equatable.dart';

import '../../../../core/enums/request_status.dart';
import '../../domain/entities/exam_report.dart';
import '../../domain/entities/student_overview.dart';

class TutorState extends Equatable {
  const TutorState({
    this.status = RequestStatus.initial,
    this.students = const [],
    this.reports = const [],
    this.selectedReportExamId,
    this.errorMessage,
    this.successMessage,
  });

  final RequestStatus status;
  final List<StudentOverview> students;
  final List<ExamReport> reports;
  final String? selectedReportExamId;
  final String? errorMessage;
  final String? successMessage;

  TutorState copyWith({
    RequestStatus? status,
    List<StudentOverview>? students,
    List<ExamReport>? reports,
    String? selectedReportExamId,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return TutorState(
      status: status ?? this.status,
      students: students ?? this.students,
      reports: reports ?? this.reports,
      selectedReportExamId: selectedReportExamId ?? this.selectedReportExamId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    students,
    reports,
    selectedReportExamId,
    errorMessage,
    successMessage,
  ];
}
