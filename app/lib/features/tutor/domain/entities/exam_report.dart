import 'package:equatable/equatable.dart';

class ExamReport extends Equatable {
  const ExamReport({
    required this.examId,
    required this.studentId,
    required this.studentName,
    required this.score,
    required this.answeredQuestions,
    required this.totalQuestions,
    this.submittedAt,
  });

  final String examId;
  final String studentId;
  final String studentName;
  final int score;
  final int answeredQuestions;
  final int totalQuestions;
  final DateTime? submittedAt;

  @override
  List<Object?> get props => [
    examId,
    studentId,
    studentName,
    score,
    answeredQuestions,
    totalQuestions,
    submittedAt,
  ];
}
