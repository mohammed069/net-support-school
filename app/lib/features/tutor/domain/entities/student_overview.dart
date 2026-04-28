import 'package:equatable/equatable.dart';

class StudentOverview extends Equatable {
  const StudentOverview({
    required this.id,
    required this.displayName,
    required this.email,
    required this.isLocked,
    required this.examStarted,
    required this.hasSubmitted,
    required this.currentStatus,
    this.photoUrl,
    this.activeExamId,
    this.activeExamTitle,
    this.examDurationMinutes,
    this.updatedAt,
  });

  final String id;
  final String displayName;
  final String email;
  final bool isLocked;
  final bool examStarted;
  final bool hasSubmitted;
  final String currentStatus;
  final String? photoUrl;
  final String? activeExamId;
  final String? activeExamTitle;
  final int? examDurationMinutes;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    displayName,
    email,
    isLocked,
    examStarted,
    hasSubmitted,
    currentStatus,
    photoUrl,
    activeExamId,
    activeExamTitle,
    examDurationMinutes,
    updatedAt,
  ];
}
