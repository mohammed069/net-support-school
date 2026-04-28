import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    super.photoUrl,
    super.createdAt,
  });

  factory AppUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return AppUserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      role: UserRoleX.fromValue(data['role'] as String?),
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role.value,
      'photoUrl': photoUrl,
      'createdAt':
          createdAt == null
              ? FieldValue.serverTimestamp()
              : Timestamp.fromDate(createdAt!),
    };
  }
}
