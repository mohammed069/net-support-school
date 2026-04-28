import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/exam_report_model.dart';
import '../models/student_overview_model.dart';

class TutorRemoteDataSource {
  TutorRemoteDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<List<StudentOverviewModel>> watchStudents() {
    return _firestore
        .collection(FirestoreCollections.students)
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(StudentOverviewModel.fromFirestore)
              .toList(growable: false),
        );
  }

  Future<void> setStudentLock({
    required String studentId,
    required bool isLocked,
  }) async {
    await _firestore
        .collection(FirestoreCollections.students)
        .doc(studentId)
        .set({
          'isLocked': isLocked,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> startExam({
    required String examId,
    required String examTitle,
    required List<String> studentIds,
    required int durationMinutes,
  }) async {
    final batch = _firestore.batch();
    final examRef = _firestore
        .collection(FirestoreCollections.exams)
        .doc(examId);
    batch.set(examRef, {
      'isActive': true,
      'assignedStudentIds': studentIds,
      'startedAt': FieldValue.serverTimestamp(),
      'durationMinutes': durationMinutes,
    }, SetOptions(merge: true));

    for (final studentId in studentIds) {
      final studentRef = _firestore
          .collection(FirestoreCollections.students)
          .doc(studentId);
      batch.set(studentRef, {
        'activeExamId': examId,
        'activeExamTitle': examTitle,
        'examStarted': true,
        'hasSubmitted': false,
        'currentStatus': 'started',
        'examDurationMinutes': durationMinutes,
        'examAssignedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> stopExam({
    required String examId,
    required List<String> studentIds,
  }) async {
    final batch = _firestore.batch();
    final examRef = _firestore
        .collection(FirestoreCollections.exams)
        .doc(examId);
    batch.set(examRef, {
      'isActive': false,
      'assignedStudentIds': const <String>[],
    }, SetOptions(merge: true));

    for (final studentId in studentIds) {
      final studentRef = _firestore
          .collection(FirestoreCollections.students)
          .doc(studentId);
      batch.set(studentRef, {
        'activeExamId': null,
        'activeExamTitle': null,
        'examStarted': false,
        'currentStatus': 'idle',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Stream<List<ExamReportModel>> watchReports(String examId) {
    return _firestore
        .collection(FirestoreCollections.answers)
        .where('examId', isEqualTo: examId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ExamReportModel.fromFirestore)
              .toList(growable: false),
        );
  }
}
