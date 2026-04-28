import '../entities/exam.dart';
import '../entities/exam_details.dart';
import '../entities/exam_question.dart';

abstract class ExamRepository {
  Stream<List<Exam>> watchExams();

  Future<Exam> createExam({
    required String title,
    required String description,
    required int durationMinutes,
    required String createdBy,
  });

  Future<void> addQuestion({
    required String examId,
    required ExamQuestion question,
  });

  Future<ExamDetails> loadExamDetails(String examId);
}
