import '../../domain/entities/exam.dart';
import '../../domain/entities/exam_details.dart';
import '../../domain/entities/exam_question.dart';
import '../../domain/repositories/exam_repository.dart';
import '../datasources/exam_remote_data_source.dart';
import '../models/exam_question_model.dart';

class ExamRepositoryImpl implements ExamRepository {
  ExamRepositoryImpl({required ExamRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ExamRemoteDataSource _remoteDataSource;

  @override
  Stream<List<Exam>> watchExams() => _remoteDataSource.watchExams();

  @override
  Future<Exam> createExam({
    required String title,
    required String description,
    required int durationMinutes,
    required String createdBy,
  }) {
    return _remoteDataSource.createExam(
      title: title,
      description: description,
      durationMinutes: durationMinutes,
      createdBy: createdBy,
    );
  }

  @override
  Future<void> addQuestion({
    required String examId,
    required ExamQuestion question,
  }) {
    return _remoteDataSource.addQuestion(
      examId: examId,
      question: ExamQuestionModel(
        id: question.id,
        question: question.question,
        options: question.options,
        correctAnswerIndex: question.correctAnswerIndex,
        order: question.order,
      ),
    );
  }

  @override
  Future<ExamDetails> loadExamDetails(String examId) async {
    final exam = await _remoteDataSource.getExam(examId);
    final questions = await _remoteDataSource.getQuestions(examId);
    return ExamDetails(exam: exam, questions: questions);
  }
}
