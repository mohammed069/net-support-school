import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/exam.dart';

class ExamModel extends Exam {
  const ExamModel({
    required super.id,
    required super.title,
    required super.description,
    required super.durationMinutes,
    required super.createdBy,
    required super.isActive,
    super.assignedStudentIds,
    super.createdAt,
    super.startedAt,
  });

  factory ExamModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ExamModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? 0,
      createdBy: data['createdBy'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? false,
      assignedStudentIds:
          (data['assignedStudentIds'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'durationMinutes': durationMinutes,
      'createdBy': createdBy,
      'isActive': isActive,
      'assignedStudentIds': assignedStudentIds,
      'createdAt':
          createdAt == null
              ? FieldValue.serverTimestamp()
              : Timestamp.fromDate(createdAt!),
      'startedAt': startedAt == null ? null : Timestamp.fromDate(startedAt!),
    };
  }
}
