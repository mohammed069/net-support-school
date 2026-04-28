import '../entities/exam_report.dart';
import '../entities/student_overview.dart';
import '../repositories/tutor_repository.dart';

class WatchStudentsUseCase {
  const WatchStudentsUseCase(this._repository);

  final TutorRepository _repository;

  Stream<List<StudentOverview>> call() => _repository.watchStudents();
}

class SetStudentLockUseCase {
  const SetStudentLockUseCase(this._repository);

  final TutorRepository _repository;

  Future<void> call({required String studentId, required bool isLocked}) {
    return _repository.setStudentLock(studentId: studentId, isLocked: isLocked);
  }
}

class StartExamForStudentsUseCase {
  const StartExamForStudentsUseCase(this._repository);

  final TutorRepository _repository;

  Future<void> call({
    required String examId,
    required String examTitle,
    required List<String> studentIds,
    required int durationMinutes,
  }) {
    return _repository.startExam(
      examId: examId,
      examTitle: examTitle,
      studentIds: studentIds,
      durationMinutes: durationMinutes,
    );
  }
}

class StopExamForStudentsUseCase {
  const StopExamForStudentsUseCase(this._repository);

  final TutorRepository _repository;

  Future<void> call({
    required String examId,
    required List<String> studentIds,
  }) {
    return _repository.stopExam(examId: examId, studentIds: studentIds);
  }
}

class WatchExamReportsUseCase {
  const WatchExamReportsUseCase(this._repository);

  final TutorRepository _repository;

  Stream<List<ExamReport>> call(String examId) =>
      _repository.watchReports(examId);
}
