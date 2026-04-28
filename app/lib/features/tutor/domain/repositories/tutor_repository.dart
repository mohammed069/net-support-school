import '../entities/exam_report.dart';
import '../entities/student_overview.dart';

abstract class TutorRepository {
  Stream<List<StudentOverview>> watchStudents();

  Future<void> setStudentLock({
    required String studentId,
    required bool isLocked,
  });

  Future<void> startExam({
    required String examId,
    required String examTitle,
    required List<String> studentIds,
    required int durationMinutes,
  });

  Future<void> stopExam({
    required String examId,
    required List<String> studentIds,
  });

  Stream<List<ExamReport>> watchReports(String examId);
}
