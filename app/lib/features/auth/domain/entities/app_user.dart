import 'package:equatable/equatable.dart';

enum UserRole { student, tutor, unknown }

extension UserRoleX on UserRole {
  String get value => name;

  bool get isStudent => this == UserRole.student;
  bool get isTutor => this == UserRole.tutor;

  static UserRole fromValue(String? rawValue) {
    return UserRole.values.firstWhere(
      (role) => role.name == rawValue,
      orElse: () => UserRole.unknown,
    );
  }
}

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? photoUrl;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, email, name, role, photoUrl, createdAt];
}
