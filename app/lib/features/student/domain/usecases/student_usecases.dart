import '../entities/student_session.dart';
import '../repositories/student_repository.dart';

class WatchStudentSessionUseCase {
  const WatchStudentSessionUseCase(this._repository);

  final StudentRepository _repository;

  Stream<StudentSession?> call(String studentId) {
    return _repository.watchSession(studentId);
  }
}

class MarkExamStartedUseCase {
  const MarkExamStartedUseCase(this._repository);

  final StudentRepository _repository;

  Future<void> call(String studentId) => _repository.markExamStarted(studentId);
}

class SubmitExamAnswersUseCase {
  const SubmitExamAnswersUseCase(this._repository);

  final StudentRepository _repository;

  Future<void> call({
    required String studentId,
    required String studentName,
    required String examId,
    required Map<String, int> answers,
  }) {
    return _repository.submitAnswers(
      studentId: studentId,
      studentName: studentName,
      examId: examId,
      answers: answers,
    );
  }
}
