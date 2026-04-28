import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/exam_question.dart';

class ExamQuestionModel extends ExamQuestion {
  const ExamQuestionModel({
    required super.id,
    required super.question,
    required super.options,
    required super.correctAnswerIndex,
    required super.order,
  });

  factory ExamQuestionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return ExamQuestionModel(
      id: doc.id,
      question: data['question'] as String? ?? '',
      options:
          (data['options'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
      correctAnswerIndex: (data['correctAnswerIndex'] as num?)?.toInt() ?? 0,
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
