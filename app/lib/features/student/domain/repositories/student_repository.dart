import '../entities/student_session.dart';

abstract class StudentRepository {
  Stream<StudentSession?> watchSession(String studentId);

  Future<void> markExamStarted(String studentId);

  Future<void> submitAnswers({
    required String studentId,
    required String studentName,
    required String examId,
    required Map<String, int> answers,
  });
}
