import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/exam_model.dart';
import '../models/exam_question_model.dart';

class ExamRemoteDataSource {
  ExamRemoteDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<List<ExamModel>> watchExams() {
    return _firestore
        .collection(FirestoreCollections.exams)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ExamModel.fromFirestore)
              .toList(growable: false),
        );
  }

  Future<ExamModel> createExam({
    required String title,
    required String description,
    required int durationMinutes,
    required String createdBy,
  }) async {
    final examRef = _firestore.collection(FirestoreCollections.exams).doc();
    final model = ExamModel(
      id: examRef.id,
      title: title,
      description: description,
      durationMinutes: durationMinutes,
      createdBy: createdBy,
      isActive: false,
      createdAt: DateTime.now(),
    );

    await examRef.set(model.toFirestore());
    return model;
  }

  Future<void> addQuestion({
    required String examId,
    required ExamQuestionModel question,
  }) async {
    await _firestore
        .collection(FirestoreCollections.exams)
        .doc(examId)
        .collection(FirestoreCollections.questions)
        .doc(question.id)
        .set(question.toFirestore());
  }

  Future<ExamModel> getExam(String examId) async {
    final snapshot =
        await _firestore
            .collection(FirestoreCollections.exams)
            .doc(examId)
            .get();
    return ExamModel.fromFirestore(snapshot);
  }

  Future<List<ExamQuestionModel>> getQuestions(String examId) async {
    final snapshot =
        await _firestore
            .collection(FirestoreCollections.exams)
            .doc(examId)
            .collection(FirestoreCollections.questions)
            .orderBy('order')
            .get();

    return snapshot.docs
        .map(ExamQuestionModel.fromFirestore)
        .toList(growable: false);
  }
}
