import 'package:equatable/equatable.dart';

import 'exam.dart';
import 'exam_question.dart';

class ExamDetails extends Equatable {
  const ExamDetails({required this.exam, required this.questions});

  final Exam exam;
  final List<ExamQuestion> questions;

  @override
  List<Object?> get props => [exam, questions];
}
