import '../../domain/entities/student_session.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_data_source.dart';

class StudentRepositoryImpl implements StudentRepository {
  StudentRepositoryImpl({required StudentRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final StudentRemoteDataSource _remoteDataSource;

  @override
  Stream<StudentSession?> watchSession(String studentId) {
    return _remoteDataSource.watchSession(studentId);
  }

  @override
  Future<void> markExamStarted(String studentId) {
    return _remoteDataSource.markExamStarted(studentId);
  }

  @override
  Future<void> submitAnswers({
    required String studentId,
    required String studentName,
    required String examId,
    required Map<String, int> answers,
  }) {
    return _remoteDataSource.submitAnswers(
      studentId: studentId,
      studentName: studentName,
      examId: examId,
      answers: answers,
    );
  }
}
