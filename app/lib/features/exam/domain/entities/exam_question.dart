import 'package:equatable/equatable.dart';

class ExamQuestion extends Equatable {
  const ExamQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.order,
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final int order;

  @override
  List<Object?> get props => [id, question, options, correctAnswerIndex, order];
}
