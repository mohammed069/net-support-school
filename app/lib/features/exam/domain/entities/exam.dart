import 'package:equatable/equatable.dart';

class Exam extends Equatable {
  const Exam({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.createdBy,
    required this.isActive,
    this.assignedStudentIds = const [],
    this.createdAt,
    this.startedAt,
  });

  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final String createdBy;
  final bool isActive;
  final List<String> assignedStudentIds;
  final DateTime? createdAt;
  final DateTime? startedAt;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    durationMinutes,
    createdBy,
    isActive,
    assignedStudentIds,
    createdAt,
    startedAt,
  ];
}
