import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/student_session.dart';

class StudentSessionModel extends StudentSession {
  const StudentSessionModel({
    required super.id,
    required super.displayName,
    required super.email,
    required super.role,
    required super.isLocked,
    required super.examStarted,
    required super.hasSubmitted,
    required super.currentStatus,
    super.photoUrl,
    super.activeExamId,
    super.activeExamTitle,
    super.examDurationMinutes,
    super.examAssignedAt,
    super.updatedAt,
  });

  factory StudentSessionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return StudentSessionModel(
      id: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'student',
      isLocked: data['isLocked'] as bool? ?? false,
      examStarted: data['examStarted'] as bool? ?? false,
      hasSubmitted: data['hasSubmitted'] as bool? ?? false,
      currentStatus: data['currentStatus'] as String? ?? 'idle',
      photoUrl: data['photoUrl'] as String?,
      activeExamId: data['activeExamId'] as String?,
      activeExamTitle: data['activeExamTitle'] as String?,
      examDurationMinutes: (data['examDurationMinutes'] as num?)?.toInt(),
      examAssignedAt: (data['examAssignedAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
