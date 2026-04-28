import 'package:equatable/equatable.dart';

class StudentSession extends Equatable {
  const StudentSession({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    required this.isLocked,
    required this.examStarted,
    required this.hasSubmitted,
    required this.currentStatus,
    this.photoUrl,
    this.activeExamId,
    this.activeExamTitle,
    this.examDurationMinutes,
    this.examAssignedAt,
    this.updatedAt,
  });

  final String id;
  final String displayName;
  final String email;
  final String role;
  final bool isLocked;
  final bool examStarted;
  final bool hasSubmitted;
  final String currentStatus;
  final String? photoUrl;
  final String? activeExamId;
  final String? activeExamTitle;
  final int? examDurationMinutes;
  final DateTime? examAssignedAt;
  final DateTime? updatedAt;

  bool get hasActiveExam => activeExamId != null && activeExamId!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    displayName,
    email,
    role,
    isLocked,
    examStarted,
    hasSubmitted,
    currentStatus,
    photoUrl,
    activeExamId,
    activeExamTitle,
    examDurationMinutes,
    examAssignedAt,
    updatedAt,
  ];
}
