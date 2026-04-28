import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/student_session_model.dart';

class StudentRemoteDataSource {
  StudentRemoteDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<StudentSessionModel?> watchSession(String studentId) {
    return _firestore
        .collection(FirestoreCollections.students)
        .doc(studentId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            return null;
          }
          return StudentSessionModel.fromFirestore(snapshot);
        });
  }

  Future<void> markExamStarted(String studentId) async {
    await _firestore
        .collection(FirestoreCollections.students)
        .doc(studentId)
        .set({
          'examStarted': true,
          'hasSubmitted': false,
          'currentStatus': 'started',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> submitAnswers({
    required String studentId,
    required String studentName,
    required String examId,
    required Map<String, int> answers,
  }) async {
    final questionSnapshot =
        await _firestore
            .collection(FirestoreCollections.exams)
            .doc(examId)
            .collection(FirestoreCollections.questions)
            .get();

    var score = 0;
    for (final doc in questionSnapshot.docs) {
      final correctAnswer = (doc.data()['correctAnswerIndex'] as num?)?.toInt();
      if (correctAnswer != null && answers[doc.id] == correctAnswer) {
        score++;
      }
    }

    final answeredCount = answers.length;
    await _firestore
        .collection(FirestoreCollections.answers)
        .doc('${examId}_$studentId')
        .set({
          'examId': examId,
          'studentId': studentId,
          'studentName': studentName,
          'selectedAnswers': answers,
          'score': score,
          'answeredQuestions': answeredCount,
          'totalQuestions': questionSnapshot.docs.length,
          'submittedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    await _firestore
        .collection(FirestoreCollections.students)
        .doc(studentId)
        .set({
          'hasSubmitted': true,
          'examStarted': false,
          'currentStatus': 'finished',
          'activeExamId': null,
          'activeExamTitle': null,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }
}
