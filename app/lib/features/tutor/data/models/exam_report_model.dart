import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/exam_report.dart';

class ExamReportModel extends ExamReport {
  const ExamReportModel({
    required super.examId,
    required super.studentId,
    required super.studentName,
    required super.score,
    required super.answeredQuestions,
    required super.totalQuestions,
    super.submittedAt,
  });

  factory ExamReportModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return ExamReportModel(
      examId: data['examId'] as String? ?? '',
      studentId: data['studentId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      score: (data['score'] as num?)?.toInt() ?? 0,
      answeredQuestions: (data['answeredQuestions'] as num?)?.toInt() ?? 0,
      totalQuestions: (data['totalQuestions'] as num?)?.toInt() ?? 0,
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
    );
  }
}
