import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/student_overview.dart';

class StudentOverviewModel extends StudentOverview {
  const StudentOverviewModel({
    required super.id,
    required super.displayName,
    required super.email,
    required super.isLocked,
    required super.examStarted,
    required super.hasSubmitted,
    required super.currentStatus,
    super.photoUrl,
    super.activeExamId,
    super.activeExamTitle,
    super.examDurationMinutes,
    super.updatedAt,
  });

  factory StudentOverviewModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return StudentOverviewModel(
      id: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      isLocked: data['isLocked'] as bool? ?? false,
      examStarted: data['examStarted'] as bool? ?? false,
      hasSubmitted: data['hasSubmitted'] as bool? ?? false,
      currentStatus: data['currentStatus'] as String? ?? 'idle',
      photoUrl: data['photoUrl'] as String?,
      activeExamId: data['activeExamId'] as String?,
      activeExamTitle: data['activeExamTitle'] as String?,
      examDurationMinutes: (data['examDurationMinutes'] as num?)?.toInt(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
