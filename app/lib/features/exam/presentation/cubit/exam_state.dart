import 'package:equatable/equatable.dart';

import '../../../../core/enums/request_status.dart';
import '../../domain/entities/exam.dart';
import '../../domain/entities/exam_details.dart';

class ExamState extends Equatable {
  const ExamState({
    this.status = RequestStatus.initial,
    this.exams = const [],
    this.examDetails,
    this.selectedAnswers = const {},
    this.remainingSeconds = 0,
    this.errorMessage,
    this.successMessage,
    this.hasSubmitted = false,
  });

  final RequestStatus status;
  final List<Exam> exams;
  final ExamDetails? examDetails;
  final Map<String, int> selectedAnswers;
  final int remainingSeconds;
  final String? errorMessage;
  final String? successMessage;
  final bool hasSubmitted;

  String get formattedRemainingTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  ExamState copyWith({
    RequestStatus? status,
    List<Exam>? exams,
    ExamDetails? examDetails,
    Map<String, int>? selectedAnswers,
    int? remainingSeconds,
    String? errorMessage,
    String? successMessage,
    bool? hasSubmitted,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ExamState(
      status: status ?? this.status,
      exams: exams ?? this.exams,
      examDetails: examDetails ?? this.examDetails,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
    );
  }

  @override
  List<Object?> get props => [
    status,
    exams,
    examDetails,
    selectedAnswers,
    remainingSeconds,
    errorMessage,
    successMessage,
    hasSubmitted,
  ];
}
