import '../../domain/entities/exam_report.dart';
import '../../domain/entities/student_overview.dart';
import '../../domain/repositories/tutor_repository.dart';
import '../datasources/tutor_remote_data_source.dart';

class TutorRepositoryImpl implements TutorRepository {
  TutorRepositoryImpl({required TutorRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final TutorRemoteDataSource _remoteDataSource;

  @override
  Stream<List<StudentOverview>> watchStudents() =>
      _remoteDataSource.watchStudents();

  @override
  Future<void> setStudentLock({
    required String studentId,
    required bool isLocked,
  }) {
    return _remoteDataSource.setStudentLock(
      studentId: studentId,
      isLocked: isLocked,
    );
  }

  @override
  Future<void> startExam({
    required String examId,
    required String examTitle,
    required List<String> studentIds,
    required int durationMinutes,
  }) {
    return _remoteDataSource.startExam(
      examId: examId,
      examTitle: examTitle,
      studentIds: studentIds,
      durationMinutes: durationMinutes,
    );
  }

  @override
  Future<void> stopExam({
    required String examId,
    required List<String> studentIds,
  }) {
    return _remoteDataSource.stopExam(examId: examId, studentIds: studentIds);
  }

  @override
  Stream<List<ExamReport>> watchReports(String examId) {
    return _remoteDataSource.watchReports(examId);
  }
}
