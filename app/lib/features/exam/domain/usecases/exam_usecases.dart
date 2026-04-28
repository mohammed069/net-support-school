import '../entities/exam.dart';
import '../entities/exam_details.dart';
import '../entities/exam_question.dart';
import '../repositories/exam_repository.dart';

class WatchExamsUseCase {
  const WatchExamsUseCase(this._repository);

  final ExamRepository _repository;

  Stream<List<Exam>> call() => _repository.watchExams();
}

class CreateExamUseCase {
  const CreateExamUseCase(this._repository);

  final ExamRepository _repository;

  Future<Exam> call({
    required String title,
    required String description,
    required int durationMinutes,
    required String createdBy,
  }) {
    return _repository.createExam(
      title: title,
      description: description,
      durationMinutes: durationMinutes,
      createdBy: createdBy,
    );
  }
}

class AddQuestionUseCase {
  const AddQuestionUseCase(this._repository);

  final ExamRepository _repository;

  Future<void> call({required String examId, required ExamQuestion question}) {
    return _repository.addQuestion(examId: examId, question: question);
  }
}

class LoadExamDetailsUseCase {
  const LoadExamDetailsUseCase(this._repository);

  final ExamRepository _repository;

  Future<ExamDetails> call(String examId) =>
      _repository.loadExamDetails(examId);
}
